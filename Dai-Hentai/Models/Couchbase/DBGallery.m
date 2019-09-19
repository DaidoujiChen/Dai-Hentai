//
//  DBGallery.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "DBGallery.h"
#import <objc/runtime.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLDatabase+RefreshView.h"
#import "EXTScope.h"

NSNotificationName const DBGalleryTimeStampUpdateNotification = @"DBGalleryTimeStampUpdateNotification";
NSNotificationName const DBGalleryDownloadedUpdateNotification = @"DBGalleryDownloadedUpdateNotification";

typedef enum {
    DBGalleryTypeHistories,
    DBGalleryTypeDownloadeds,
    DBGalleryTypeAll
} DBGalleryType;

@implementation DBGallery

#pragma mark - Private Class Method

+ (CBLDatabase *)galleries {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"histories" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
            return;
        }
        
        CBLView *query = [db refreshViewNamed:@"query"];
        [query setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
            NSString *key = [NSString stringWithFormat:@"%@-%@", doc[@"gid"], doc[@"token"]];
            emit(key, nil);
        } version:@"1"];
        
        CBLView *sort = [db refreshViewNamed:@"sort"];
        [sort setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
            NSNumber *value = doc[@"downloaded"];
            if (!value) {
                value = @(0);
            }
            emit(doc[@"timeStamp"], value);
        } version:@"1"];
        
        objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSArray<HentaiInfo *> *)list:(DBGalleryType)type from:(NSInteger)start length:(NSInteger)length {
    CBLQuery *query = [[[self galleries] viewNamed:@"sort"] createQuery];
    query.skip = start;
    query.limit = length;
    query.descending = YES;
    switch (type) {
        case DBGalleryTypeHistories:
            query.postFilter = [NSPredicate predicateWithFormat:@"value == 0"];
            break;
            
        case DBGalleryTypeDownloadeds:
            query.postFilter = [NSPredicate predicateWithFormat:@"value == 1"];
            break;
        
        // 不設 filter 只拉出按照時間排序的歷史和下載
        case DBGalleryTypeAll:
            break;
            
        default:
            break;
    }
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"list from Fail");
        return nil;
    }
    
    if (results.count == 0) {
        return nil;
    }
    
    NSMutableArray<HentaiInfo *> *items = [NSMutableArray array];
    for (NSInteger index = 0; index < results.count; index++) {
        NSDictionary *properties = [results rowAtIndex:index].document.properties;
        HentaiInfo *info = [HentaiInfo new];
        [info restoreContents:[NSMutableDictionary dictionaryWithDictionary:properties] defaultContent:nil];
        [items addObject:info];
    }
    return items;
}

#pragma mark - Class Method

+ (NSArray<HentaiInfo *> *)all {
    CBLQuery *query = [[self galleries] createAllDocumentsQuery];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"all Fail");
        return nil;
    }
    
    if (results.count == 0) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger index = 0; index < results.count; index++) {
        NSDictionary *properties = [results rowAtIndex:index].document.properties;
        HentaiInfo *info = [HentaiInfo new];
        [info restoreContents:[NSMutableDictionary dictionaryWithDictionary:properties] defaultContent:nil];
        [items addObject:info];
    }
    return items;
}

+ (NSArray<HentaiInfo *> *)historiesFrom:(NSInteger)start length:(NSInteger)length {
    return [self list:DBGalleryTypeHistories from:start length:length];
}

+ (NSArray<HentaiInfo *> *)downloadedsFrom:(NSInteger)start length:(NSInteger)length {
    return [self list:DBGalleryTypeDownloadeds from:start length:length];
}

+ (NSArray<HentaiInfo *> *)allFrom:(NSInteger)start length:(NSInteger)length {
    return [self list:DBGalleryTypeAll from:start length:length];
}

+ (void)deleteDownloaded:(HentaiInfo *)info handler:(void (^)(void))handler onFinish:(void (^)(BOOL successed))finish {
    NSString *key = [NSString stringWithFormat:@"%@-%@", info.gid, info.token];
    CBLQuery *query = [[[DBGallery galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"deleteDownloaded Fail");
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    if (!results.count) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    BOOL isDownloaded = NO;
    CBLDocument *document = [results rowAtIndex:0].document;
    if (document.properties[@"downloaded"]) {
        isDownloaded = [document.properties[@"downloaded"] boolValue];
    }
    
    if (!isDownloaded) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    if (handler) {
        handler();
        [document purgeDocument:nil];
    }
    
    if (finish) {
        finish(YES);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DBGalleryDownloadedUpdateNotification object:self];
}

+ (void)deleteAllHistories:(void (^)(NSInteger total, NSInteger index, HentaiInfo *info))handler onFinish:(void (^)(BOOL successed))finish {
    CBLQuery *query = [[[self galleries] viewNamed:@"sort"] createQuery];
    query.postFilter = [NSPredicate predicateWithFormat:@"value == 0"];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"allHistories Fail");
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger index = 0; index < results.count; index++) {
            __block CBLDocument *document = nil;
            __block NSDictionary *properties = nil;
            dispatch_sync(dispatch_get_main_queue(), ^{
                document = [results rowAtIndex:index].document;
                if (document) {
                    properties = document.properties;
                }
            });
            if (!properties) {
                continue;
            }
            
            HentaiInfo *info = [HentaiInfo new];
            [info restoreContents:[NSMutableDictionary dictionaryWithDictionary:properties] defaultContent:nil];
            
            if (handler) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    handler(results.count, index, info);
                    [document purgeDocument:nil];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finish) {
                finish(YES);
            }
        });
    });
}

@end

@implementation HentaiInfo (Status)

- (BOOL)isDownloaded {
    NSString *key = [NSString stringWithFormat:@"%@-%@", self.gid, self.token];
    CBLQuery *query = [[[DBGallery galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"isDownloaded Fail");
        return NO;
    }
    
    BOOL isDownloaded = NO;
    if (results.count) {
        CBLDocument *document = [results rowAtIndex:0].document;
        if (document.properties[@"downloaded"]) {
            isDownloaded = [document.properties[@"downloaded"] boolValue];
        }
    }
    return isDownloaded;
}

- (void)moveToDownloaded {
    NSString *key = [NSString stringWithFormat:@"%@-%@", self.gid, self.token];
    CBLQuery *query = [[[DBGallery galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"updateUserLatestPage Fail");
        return;
    }
    
    if (!results.count) {
        return;
    }
    
    CBLDocument *document = [results rowAtIndex:0].document;
    [document update: ^BOOL(CBLUnsavedRevision *rev) {
        rev[@"downloaded"] = @(1);
        return YES;
    } error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DBGalleryDownloadedUpdateNotification object:self];
}

- (NSInteger)latestPage {
    NSString *key = [NSString stringWithFormat:@"%@-%@", self.gid, self.token];
    CBLQuery *query = [[[DBGallery galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"fetchUserLatestPage Fail");
        return 0;
    }
    
    @onExit {
        [[NSNotificationCenter defaultCenter] postNotificationName:DBGalleryTimeStampUpdateNotification object:self];
    };
    
    NSInteger userLatestPage = 0;
    if (results.count) {
        CBLDocument *document = [results rowAtIndex:0].document;
        if (document.properties[@"userLatestPage"]) {
            userLatestPage = [document.properties[@"userLatestPage"] integerValue];
        }
        [document update: ^BOOL(CBLUnsavedRevision *rev) {
            rev[@"timeStamp"] = @([[NSDate date] timeIntervalSince1970]);
            return YES;
        } error:nil];
        return userLatestPage;
    }
    
    CBLDocument *document = [[DBGallery galleries] createDocument];
    self.timeStamp = @([[NSDate date] timeIntervalSince1970]);
    [document putProperties:[self storeContents] error:nil];
    return userLatestPage;
}

- (void)setLatestPage:(NSInteger)latestPage {
    NSString *key = [NSString stringWithFormat:@"%@-%@", self.gid, self.token];
    CBLQuery *query = [[[DBGallery galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"updateUserLatestPage Fail");
        return;
    }
    
    if (results.count) {
        CBLDocument *document = [results rowAtIndex:0].document;
        [document update: ^BOOL(CBLUnsavedRevision *rev) {
            rev[@"userLatestPage"] = @(latestPage);
            return YES;
        } error:nil];
    }
}

@end
