////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMRealm_Private.hpp"
#import "RLMSchema_Private.h"
#import "RLMObject_Private.h"
#import "RLMArray_Private.hpp"
#import "RLMMigration_Private.h"
#import "RLMConstants.h"
#import "RLMObjectStore.hpp"
#import "RLMObjectSchema_Private.hpp"
#import "RLMQueryUtil.hpp"
#import "RLMUpdateChecker.hpp"
#import "RLMUtil.hpp"

#include <exception>
#include <sys/types.h>
#include <sys/sysctl.h>

#include <tightdb/version.hpp>
#include <tightdb/group_shared.hpp>
#include <tightdb/commit_log.hpp>
#include <tightdb/lang_bind_helper.hpp>

// Notification Token

@interface RLMNotificationToken ()
@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, copy) RLMNotificationBlock block;
@end

@implementation RLMNotificationToken
- (void)dealloc
{
    if (_realm || _block) {
        NSLog(@"RLMNotificationToken released without unregistering a notification. You must hold \
              on to the RLMNotificationToken returned from addNotificationBlock and call \
              removeNotification: when you no longer wish to recieve RLMRealm notifications.");
    }
}
@end

// A weak holder for an RLMRealm to allow calling performSelector:onThread: without
// a strong reference to the realm
@interface RLMWeakNotifier : NSObject
@property (nonatomic, weak) RLMRealm *realm;

- (instancetype)initWithRealm:(RLMRealm *)realm;
- (void)notify;
@end

using namespace std;
using namespace tightdb;
using namespace tightdb::util;

namespace {

// create NSException from c++ exception
__attribute__((noreturn)) void throw_objc_exception(exception &ex) {
    NSString *errorMessage = [NSString stringWithUTF8String:ex.what()];
    @throw [NSException exceptionWithName:@"RLMException" reason:errorMessage userInfo:nil];
}

// create NSError from c++ exception
NSError *make_realm_error(RLMError code, exception &ex) {
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    [details setValue:[NSString stringWithUTF8String:ex.what()] forKey:NSLocalizedDescriptionKey];
    [details setValue:@(code) forKey:@"Error Code"];
    return [NSError errorWithDomain:@"io.realm" code:code userInfo:details];
}

//
// Global RLMRealm instance cache
//
NSMutableDictionary *s_realmsPerPath;
NSMutableDictionary *s_keysPerPath;

// FIXME: In the following 3 functions, we should be identifying files by the inode,device number pair
//  rather than by the path (since the path is not a reliable identifier). This requires additional support
//  from the core library though, because the inode,device number pair needs to be taken from the open file
//  (to avoid race conditions).
RLMRealm *cachedRealm(NSString *path) {
    mach_port_t threadID = pthread_mach_thread_np(pthread_self());
    @synchronized(s_realmsPerPath) {
        return [s_realmsPerPath[path] objectForKey:@(threadID)];
    }
}

void cacheRealm(RLMRealm *realm, NSString *path) {
    mach_port_t threadID = pthread_mach_thread_np(pthread_self());
    @synchronized(s_realmsPerPath) {
        if (!s_realmsPerPath[path]) {
            s_realmsPerPath[path] = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsWeakMemory];
        }
        [s_realmsPerPath[path] setObject:realm forKey:@(threadID)];
    }
}

NSArray *realmsAtPath(NSString *path) {
    @synchronized(s_realmsPerPath) {
        return [s_realmsPerPath[path] objectEnumerator].allObjects;
    }
}

void clearRealmCache() {
    @synchronized(s_realmsPerPath) {
        for (NSMapTable *map in s_realmsPerPath.allValues) {
            [map removeAllObjects];
        }
        s_realmsPerPath = [NSMutableDictionary dictionary];
    }
    @synchronized(s_keysPerPath) {
        s_keysPerPath = [NSMutableDictionary dictionary];
    }
}

static NSString *s_defaultRealmPath = nil;
static RLMMigrationBlock s_migrationBlock;
static NSUInteger s_currentSchemaVersion = 0;

void createTablesInTransaction(RLMRealm *realm, RLMSchema *targetSchema) {
    [realm beginWriteTransaction];

    @try {
        RLMRealmCreateMetadataTables(realm);
        if (RLMRealmSchemaVersion(realm) == RLMNotVersioned) {
            RLMRealmSetSchemaVersion(realm, s_currentSchemaVersion);
        }
        RLMRealmCreateTables(realm, targetSchema, false);
    }
    @catch (NSException *) {
        [realm cancelWriteTransaction];
        @throw;
    }

    [realm commitWriteTransaction];
}

bool isDebuggerAttached() {
    int name[] = {
        CTL_KERN,
        KERN_PROC,
        KERN_PROC_PID,
        getpid()
    };

    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    if (sysctl(name, sizeof(name)/sizeof(name[0]), &info, &info_size, NULL, 0) == -1) {
        NSLog(@"sysctl() failed: %s", strerror(errno));
        return false;
    }


    return (info.kp_proc.p_flag & P_TRACED) != 0;
}

} // anonymous namespace

NSString * const c_defaultRealmFileName = @"default.realm";

@implementation RLMRealm {
    // Used for read-write realms
    NSThread *_thread;
    NSMapTable *_notificationHandlers;

    std::unique_ptr<Replication> _replication;
    std::unique_ptr<SharedGroup> _sharedGroup;

    // Used for read-only realms
    std::unique_ptr<Group> _readGroup;

    // Used for both
    Group *_group;
    BOOL _readOnly;
    BOOL _inMemory;
}

+ (BOOL)isCoreDebug {
    return tightdb::Version::has_feature(tightdb::feature_Debug);
}

+ (void)initialize {
    static bool initialized;
    if (initialized) {
        return;
    }
    initialized = true;

    // set up global realm cache
    RLMCheckForUpdates();

    // initilize realm cache
    clearRealmCache();
}

- (instancetype)initWithPath:(NSString *)path key:(NSData *)key readOnly:(BOOL)readonly inMemory:(BOOL)inMemory error:(NSError **)error {
    if (key && [key length] != 64) {
        @throw [NSException exceptionWithName:@"RLMException"
                                       reason:@"Encryption key must be exactly 64 bytes long"
                                     userInfo:nil];
    }

    if (key && isDebuggerAttached()) {
        @throw [NSException exceptionWithName:@"RLMException"
                                       reason:@"Cannot open an encrypted Realm with a debugger attached to the process"
                                     userInfo:nil];
    }

    self = [super init];
    if (self) {
        _path = path;
        _thread = [NSThread currentThread];
        _threadID = pthread_mach_thread_np(pthread_self());
        _notificationHandlers = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
        _readOnly = readonly;
        _inMemory = inMemory;
        _autorefresh = YES;

        try {
            if (readonly) {
                _readGroup = make_unique<Group>(path.UTF8String, static_cast<const char *>(key.bytes));
                _group = _readGroup.get();
            }
            else {
                _replication.reset(tightdb::makeWriteLogCollector(path.UTF8String));
                SharedGroup::DurabilityLevel durability = inMemory ? SharedGroup::durability_MemOnly :
                                                                     SharedGroup::durability_Full;
                _sharedGroup = make_unique<SharedGroup>(*_replication, durability,
                                                        static_cast<const char *>(key.bytes));
            }
        }
        catch (File::PermissionDenied &ex) {
	    NSString *mode = readonly ? @"read" : @"read-write";
	    NSString *additionalMessage = [NSString stringWithFormat:@"Unable to open a realm at path '%@'. Please use a path where your app has %@ permissions.", path, mode];
	    NSString *newMessage = [NSString stringWithFormat:@"%s\n%@", ex.what(), additionalMessage];
	    ex = File::PermissionDenied(newMessage.UTF8String);
            *error = make_realm_error(RLMErrorFilePermissionDenied, ex);
        }
        catch (File::Exists &ex) {
            *error = make_realm_error(RLMErrorFileExists, ex);
        }
        catch (File::AccessError &ex) {
            *error = make_realm_error(RLMErrorFileAccessError, ex);
        }
        catch (exception &ex) {
            *error = make_realm_error(RLMErrorFail, ex);
        }
    }
    return self;
}

- (tightdb::Group *)getOrCreateGroup {
    if (!_group) {
        _group = &const_cast<Group&>(_sharedGroup->begin_read());
    }
    return _group;
}

+ (NSString *)defaultRealmPath
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_defaultRealmPath) {
            s_defaultRealmPath = [RLMRealm writeablePathForFile:c_defaultRealmFileName];
        }
    });
    return s_defaultRealmPath;
}

+ (void)setDefaultRealmPath:(NSString *)defaultRealmPath {
    s_defaultRealmPath = defaultRealmPath;
}

+ (NSString *)writeablePathForFile:(NSString*)fileName
{
#if TARGET_OS_IPHONE
    // On iOS the Documents directory isn't user-visible, so put files there
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
#else
    // On OS X it is, so put files in Application Support. If we aren't running
    // in a sandbox, put it in a subdirectory based on the bundle identifier
    // to avoid accidentally sharing files between applications
    NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    if (![[NSProcessInfo processInfo] environment][@"APP_SANDBOX_CONTAINER_ID"]) {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        if ([identifier length] == 0) {
            identifier = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        }
        path = [path stringByAppendingPathComponent:identifier];

        // create directory
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
#endif
    return [path stringByAppendingPathComponent:fileName];
}

+ (instancetype)defaultRealm
{
    return [RLMRealm realmWithPath:[RLMRealm defaultRealmPath] readOnly:NO error:nil];
}

+ (instancetype)realmWithPath:(NSString *)path
{
    return [self realmWithPath:path readOnly:NO error:nil];
}

+ (instancetype)realmWithPath:(NSString *)path
                     readOnly:(BOOL)readonly
                        error:(NSError **)outError
{
    return [self realmWithPath:path key:nil readOnly:readonly inMemory:NO dynamic:NO schema:nil error:outError];
}

+ (instancetype)inMemoryRealmWithIdentifier:(NSString *)identifier {
    return [self realmWithPath:[RLMRealm writeablePathForFile:identifier] key:nil
                      readOnly:NO inMemory:YES dynamic:NO schema:nil error:nil];
}

+ (instancetype)encryptedRealmWithPath:(NSString *)path
                                   key:(NSData *)key
                              readOnly:(BOOL)readonly
                                 error:(NSError **)error
{
    if (!key) {
        @throw [NSException exceptionWithName:@"RLMException" reason:@"Encryption key must not be nil" userInfo:nil];
    }

    return [self realmWithPath:path key:key readOnly:readonly inMemory:NO dynamic:NO schema:nil error:error];
}

+ (instancetype)realmWithPath:(NSString *)path
                          key:(NSData *)key
                     readOnly:(BOOL)readonly
                     inMemory:(BOOL)inMemory
                      dynamic:(BOOL)dynamic
                       schema:(RLMSchema *)customSchema
                        error:(NSError **)outError
{
    if (!path || path.length == 0) {
        @throw [NSException exceptionWithName:@"RLMException"
                                       reason:@"Path is not valid"
                                     userInfo:@{@"path":(path ?: @"nil")}];
    }

    if (![NSRunLoop currentRunLoop]) {
        @throw [NSException exceptionWithName:@"realm:runloop_exception"
                                       reason:[NSString stringWithFormat:@"%@ \
                                               can only be called from a thread with a runloop.",
                                               NSStringFromSelector(_cmd)] userInfo:nil];
    }

    // try to reuse existing realm first
    __autoreleasing RLMRealm *realm = nil;
    if (!dynamic && !customSchema) {
        realm = cachedRealm(path);
    }

    if (realm) {
        // if already opened with different read permissions then throw
        if (realm->_readOnly != readonly) {
            @throw [NSException exceptionWithName:@"RLMException"
                                           reason:@"Realm at path already opened with different read permissions"
                                         userInfo:@{@"path":realm.path}];
        }
        if (realm->_inMemory != inMemory) {
            @throw [NSException exceptionWithName:@"RLMException"
                                           reason:@"Realm at path already opened with different inMemory settings"
                                         userInfo:@{@"path":realm.path}];
        }
        return realm;
    }

    if (!key) {
        @synchronized (s_keysPerPath) {
            key = s_keysPerPath[path];
        }
    }

    NSError *error = nil;
    realm = [[RLMRealm alloc] initWithPath:path key:key readOnly:readonly inMemory:inMemory error:&error];
    realm->_dynamic = dynamic;

    if (error) {
        if (outError) {
            *outError = error;
            return nil;
        }
        else {
            @throw [NSException exceptionWithName:@"RLMException"
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
    }

    if (!realm) {
        return nil;
    }

    // we need to protect the realm cache and accessors cache
    @synchronized(s_realmsPerPath) {
        // create tables, set schema, and create accessors when needed
        if (customSchema) {
            if (!dynamic) {
                @throw [NSException exceptionWithName:@"RLMException" reason:@"Custom schema only supported when using dynamic Realms" userInfo:nil];
            }
            createTablesInTransaction(realm, customSchema);
        }
        else if (dynamic) {
            createTablesInTransaction(realm, [RLMSchema dynamicSchemaFromRealm:realm]);
        }
        else if (readonly) {
            if (RLMRealmSchemaVersion(realm) == RLMNotVersioned) {
                @throw [NSException exceptionWithName:@"RLMException"
                                               reason:@"Cannot open an uninitialized realm in read-only mode"
                                             userInfo:nil];
            }
            RLMRealmSetSchema(realm, [RLMSchema sharedSchema]);
            RLMRealmCreateAccessors(realm.schema);

            cacheRealm(realm, path);
        }
        else {
            // check cache for existing cached realms with the same path
            NSArray *realms = realmsAtPath(path);
            if (realms.count) {
                // if we have a cached realm on another thread, copy without a transaction
                RLMRealmSetSchema(realm, [realms[0] schema], false);
            }
            else {
                // if we are the first realm at this path, set/align schema or perform migration if needed
                NSUInteger schemaVersion = RLMRealmSchemaVersion(realm);
                if (s_currentSchemaVersion == schemaVersion || schemaVersion == RLMNotVersioned) {
                    createTablesInTransaction(realm, [RLMSchema sharedSchema]);
                }
                else {
                    [RLMRealm migrateRealm:realm key:key];
                }

                RLMRealmCreateAccessors(realm.schema);
            }

            // initializing the schema started a read transaction, so end it
            [realm invalidate];

            // cache only realms using a shared schema
            cacheRealm(realm, path);
        }
    }

    return realm;
}

+ (void)setEncryptionKey:(NSData *)key forRealmsAtPath:(NSString *)path {
    if (!key) {
        @synchronized (s_keysPerPath) {
            [s_keysPerPath removeObjectForKey:path];
            return;
        }
    }

    if ([key length] != 64) {
        @throw [NSException exceptionWithName:@"RLMException"
                                       reason:@"Encryption key must be exactly 64 bytes"
                                     userInfo:nil];
    }

    @synchronized (s_keysPerPath) {
        s_keysPerPath[path] = key;
    }
}

+ (void)resetRealmState {
    s_currentSchemaVersion = 0;
    s_migrationBlock = NULL;
    clearRealmCache();
}

static void CheckReadWrite(RLMRealm *realm, NSString *msg=@"Cannot write to a read-only Realm") {
    if (realm->_readOnly) {
        @throw [NSException exceptionWithName:@"RLMException"
                                       reason:msg
                                     userInfo:nil];
    }
}

- (RLMNotificationToken *)addNotificationBlock:(RLMNotificationBlock)block {
    RLMCheckThread(self);
    CheckReadWrite(self, @"Read-only Realms do not change and do not have change notifications");
    if (!block) {
        @throw [NSException exceptionWithName:@"RLMException" reason:@"The notification block should not be nil" userInfo:nil];
    }

    RLMNotificationToken *token = [[RLMNotificationToken alloc] init];
    token.realm = self;
    token.block = block;
    [_notificationHandlers setObject:token forKey:token];
    return token;
}

- (void)removeNotification:(RLMNotificationToken *)token {
    RLMCheckThread(self);
    if (token) {
        [_notificationHandlers removeObjectForKey:token];
        token.realm = nil;
        token.block = nil;
    }
}

- (void)sendNotifications:(NSString *)notification {
    NSAssert(!_readOnly, @"Read-only realms do not have notifications");

    // call this realms notification blocks
    for (RLMNotificationToken *token in [_notificationHandlers copy]) {
        if (token.block) {
            token.block(notification, self);
        }
    }
}

- (void)beginWriteTransaction {
    CheckReadWrite(self);
    RLMCheckThread(self);

    if (!self.inWriteTransaction) {
        try {
            // if the upgrade to write will move the transaction forward,
            // announce the change after promoting
            bool announce = _sharedGroup->has_changed();

            // begin the read transaction if needed
            [self getOrCreateGroup];

            LangBindHelper::promote_to_write(*_sharedGroup);

            if (announce) {
                [self sendNotifications:RLMRealmDidChangeNotification];
            }

            // update state and make all objects in this realm writable
            _inWriteTransaction = YES;
        }
        catch (std::exception& ex) {
            // File access errors are treated as exceptions here since they should not occur after the shared
            // group has already been successfully opened on the file and memory mapped. The shared group constructor handles
            // the excepted error related to file access.
            throw_objc_exception(ex);
        }
    } else {
        @throw [NSException exceptionWithName:@"RLMException" reason:@"The Realm is already in a writetransaction" userInfo:nil];
    }
}

- (void)commitWriteTransaction {
    CheckReadWrite(self);
    RLMCheckThread(self);

    if (self.inWriteTransaction) {
        try {
            LangBindHelper::commit_and_continue_as_read(*_sharedGroup);

            // update state and make all objects in this realm read-only
            _inWriteTransaction = NO;

            // notify other realm instances of changes
            NSArray *realms = realmsAtPath(_path);
            for (RLMRealm *realm in realms) {
                if (![realm isEqual:self]) {
                    RLMWeakNotifier *notifier = [[RLMWeakNotifier alloc] initWithRealm:realm];
                    [notifier performSelector:@selector(notify)
                                     onThread:realm->_thread withObject:nil waitUntilDone:NO];
                }
            }

            // send local notification
            [self sendNotifications:RLMRealmDidChangeNotification];
        }
        catch (std::exception& ex) {
            throw_objc_exception(ex);
        }
    } else {
       @throw [NSException exceptionWithName:@"RLMException" reason:@"Can't commit a non-existing write transaction" userInfo:nil];
    }
}

- (void)transactionWithBlock:(void(^)(void))block {
    [self beginWriteTransaction];
    block();
    if (_inWriteTransaction) {
        [self commitWriteTransaction];
    }
}

- (void)cancelWriteTransaction {
    CheckReadWrite(self);
    RLMCheckThread(self);

    if (self.inWriteTransaction) {
        try {
            LangBindHelper::rollback_and_continue_as_read(*_sharedGroup);
            _inWriteTransaction = NO;
        }
        catch (std::exception& ex) {
            throw_objc_exception(ex);
        }
    } else {
        @throw [NSException exceptionWithName:@"RLMException" reason:@"Can't cancel a non-existing write transaction" userInfo:nil];
    }
}

- (void)invalidate {
    RLMCheckThread(self);
    CheckReadWrite(self, @"Cannot invalidate a read-only realm");

    if (_inWriteTransaction) {
        NSLog(@"WARNING: An RLMRealm instance was invalidated during a write "
              "transaction and all pending changes have been rolled back.");
        [self cancelWriteTransaction];
    }
    if (!_group) {
        // Nothing to do if the read transaction hasn't been begun
        return;
    }

    _sharedGroup->end_read();
    _group = nullptr;
    for (RLMObjectSchema *objectSchema in _schema.objectSchema) {
        objectSchema->_table.reset();
    }
}

- (void)dealloc {
    if (_inWriteTransaction) {
        [self cancelWriteTransaction];
        NSLog(@"WARNING: An RLMRealm instance was deallocated during a write transaction and all "
              "pending changes have been rolled back. Make sure to retain a reference to the "
              "RLMRealm for the duration of the write transaction.");
    }
}

- (void)handleExternalCommit {
    RLMCheckThread(self);
    NSAssert(!_readOnly, @"Read-only realms do not have notifications");
    try {
        if (_sharedGroup->has_changed()) { // Throws
            if (_autorefresh) {
                if (_group) {
                    LangBindHelper::advance_read(*_sharedGroup);
                }
                [self sendNotifications:RLMRealmDidChangeNotification];
            }
            else {
                [self sendNotifications:RLMRealmRefreshRequiredNotification];
            }
        }
    }
    catch (exception &ex) {
        throw_objc_exception(ex);
    }
}

- (BOOL)refresh {
    RLMCheckThread(self);
    CheckReadWrite(self, @"Cannot refresh a read-only realm (external modifications to read only realms are not supported)");

    // can't be any new changes if we're in a write transaction
    if (self.inWriteTransaction) {
        return NO;
    }

    try {
        // advance transaction if database has changed
        if (_sharedGroup->has_changed()) { // Throws
            if (_group) {
                LangBindHelper::advance_read(*_sharedGroup);
            }
            else {
                // Create the read transaction
                [self getOrCreateGroup];
            }
            [self sendNotifications:RLMRealmDidChangeNotification];
            return YES;
        }
        return NO;
    }
    catch (exception &ex) {
        throw_objc_exception(ex);
    }
}

- (void)addObject:(RLMObject *)object {
    RLMAddObjectToRealm(object, self);
}

- (void)addObjects:(id<NSFastEnumeration>)array {
    for (RLMObject *obj in array) {
        if (![obj isKindOfClass:[RLMObject class]]) {
            NSString *msg = [NSString stringWithFormat:@"Cannot insert objects of type %@ with addObjects:. Only RLMObjects are supported.", NSStringFromClass(obj.class)];
            @throw [NSException exceptionWithName:@"RLMException" reason:msg userInfo:nil];
        }
        [self addObject:obj];
    }
}

- (void)addOrUpdateObject:(RLMObject *)object {
    // verify primary key
    if (!object.objectSchema.primaryKeyProperty) {
        NSString *reason = [NSString stringWithFormat:@"'%@' does not have a primary key and can not be updated", object.objectSchema.className];
        @throw [NSException exceptionWithName:@"RLMExecption" reason:reason userInfo:nil];
    }

    RLMAddObjectToRealm(object, self, RLMSetFlagUpdateOrCreate);
}

- (void)addOrUpdateObjectsFromArray:(id)array {
    for (RLMObject *obj in array) {
        [self addOrUpdateObject:obj];
    }
}

- (void)deleteObject:(RLMObject *)object {
    RLMDeleteObjectFromRealm(object, self);
}

- (void)deleteObjects:(id)array {
    if (NSArray *nsArray = RLMDynamicCast<NSArray>(array)) {
        // for arrays and standalone delete each individually
        for (id obj in nsArray) {
            if ([obj isKindOfClass:RLMObject.class]) {
                RLMDeleteObjectFromRealm(obj, self);
            }
        }
    }
    else if (RLMArray *rlmArray = RLMDynamicCast<RLMArray>(array)) {
        // call deleteObjectsFromRealm for our RLMArray
        [rlmArray deleteObjectsFromRealm];
    }
    else if (RLMResults *rlmResults = RLMDynamicCast<RLMResults>(array)) {
        // call deleteObjectsFromRealm for our RLMResults
        [rlmResults deleteObjectsFromRealm];
    }
    else {
        @throw [NSException exceptionWithName:@"RLMException" reason:@"Invalid array type - container must be an RLMArray, RLMArray, or NSArray of RLMObjects" userInfo:nil];
    }
}

- (void)deleteAllObjects {
    RLMDeleteAllObjectsFromRealm(self);
}

- (RLMResults *)allObjects:(NSString *)objectClassName {
    return RLMGetObjects(self, objectClassName, nil);
}

- (RLMResults *)objects:(NSString *)objectClassName where:(NSString *)predicateFormat, ... {
    va_list args;
    RLM_VARARG(predicateFormat, args);
    return [self objects:objectClassName where:predicateFormat args:args];
}

- (RLMResults *)objects:(NSString *)objectClassName where:(NSString *)predicateFormat args:(va_list)args {
    return [self objects:objectClassName withPredicate:[NSPredicate predicateWithFormat:predicateFormat arguments:args]];
}

- (RLMResults *)objects:(NSString *)objectClassName withPredicate:(NSPredicate *)predicate {
    return RLMGetObjects(self, objectClassName, predicate);
}

+ (void)setSchemaVersion:(NSUInteger)version withMigrationBlock:(RLMMigrationBlock)block {
    s_currentSchemaVersion = version;
    s_migrationBlock = block;
}

+ (NSError *)migrateRealmAtPath:(NSString *)realmPath {
    NSData *key;
    @synchronized (s_keysPerPath) {
        key = s_keysPerPath[realmPath];
    }

    NSError *error;
    RLMRealm *realm = [RLMRealm realmWithPath:realmPath key:key readOnly:NO inMemory:NO dynamic:YES schema:nil error:&error];
    if (error) {
        return error;
    }

    return [self migrateRealm:realm key:key];
}

+ (NSError *)migrateEncryptedRealmAtPath:(NSString *)realmPath key:(NSData *)key {
    if (!key) {
        @throw [NSException exceptionWithName:@"RLMException" reason:@"Encryption key must not be nil" userInfo:nil];
    }

    NSError *error;
    RLMRealm *realm = [self realmWithPath:realmPath key:key readOnly:NO inMemory:NO dynamic:YES schema:nil error:&error];
    if (error) {
        return error;
    }

    return [self migrateRealm:realm key:key];
}

+ (NSError *)migrateRealm:(RLMRealm *)realm key:(NSData *)key {
    NSError *error;
    RLMMigration *migration = [RLMMigration migrationForRealm:realm key:key error:&error];
    if (error) {
        return error;
    }

    // only perform migration if current version is > on-disk version
    NSUInteger schemaVersion = RLMRealmSchemaVersion(migration.realm);
    if (schemaVersion < s_currentSchemaVersion) {
        [migration migrateWithBlock:s_migrationBlock version:s_currentSchemaVersion];
    }
    else if (schemaVersion > s_currentSchemaVersion && schemaVersion != RLMNotVersioned) {
        if (!s_migrationBlock) {
            @throw [NSException exceptionWithName:@"RLMException"
                                           reason:@"No migration block specified for a Realm with a schema version greater than 0. You must supply a valid schema version and migration block before accessing any Realm by calling `setSchemaVersion:withMigrationBlock:`"
                                         userInfo:@{@"path" : migration.realm.path}];
        }
        else {
            @throw [NSException exceptionWithName:@"RLMException"
                                           reason:@"Realm version is higher than the current version provided to `setSchemaVersion:withMigrationBlock:`"
                                         userInfo:@{@"path" : migration.realm.path}];
        }
    }

    return nil;
}

- (RLMObject *)createObject:(NSString *)className withObject:(id)object {
    return RLMCreateObjectInRealmWithValue(self, className, object);
}

- (BOOL)writeCopyToPath:(NSString *)path error:(NSError **)error {
    BOOL success = YES;

    try {
        self.group->write(path.UTF8String);
    }
    catch (File::PermissionDenied &ex) {
        success = NO;
        if (error) {
            *error = make_realm_error(RLMErrorFilePermissionDenied, ex);
        }
    }
    catch (File::Exists &ex) {
        success = NO;
        if (error) {
            *error = make_realm_error(RLMErrorFileExists, ex);
        }
    }
    catch (File::AccessError &ex) {
        success = NO;
        if (error) {
            *error = make_realm_error(RLMErrorFileAccessError, ex);
        }
    }
    catch (exception &ex) {
        success = NO;
        if (error) {
            *error = make_realm_error(RLMErrorFail, ex);
        }
    }

    return success;
}

@end

@implementation RLMWeakNotifier
- (instancetype)initWithRealm:(RLMRealm *)realm
{
    self = [super init];
    if (self) {
        _realm = realm;
    }
    return self;
}

- (void)notify
{
    [_realm handleExternalCommit];
}
@end
