//
//  Couchbase.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/10.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "Couchbase.h"
#import <objc/runtime.h>
#import "HentaiParser.h"

@implementation Couchbase

#pragma mark - Private Class Method

+ (CBLDatabase *)galleries {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"galleries" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
        }
        else {
            
            CBLView *view = [db viewNamed:@"query"];
            [view setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
                NSString *key = [NSString stringWithFormat:@"%@-%@-%@", doc[@"gid"], doc[@"token"], doc[@"index"]];
                emit(key, nil);
            } version:@"1"];
            
            objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (CBLDatabase *)search {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"search" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
        }
        else {
            objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (CBLDatabase *)histories {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"histories" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
        }
        else {
            
            CBLView *query = [db viewNamed:@"query"];
            [query setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
                NSString *key = [NSString stringWithFormat:@"%@-%@", doc[@"gid"], doc[@"token"]];
                emit(key, nil);
            } version:@"1"];
            
            CBLView *sort = [db viewNamed:@"sort"];
            [sort setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
                emit(doc[@"timeStamp"], nil);
            } version:@"1"];
            
            objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Class Method

#pragma mark * Gallery Pages

+ (void)addGalleryBy:(NSString *)gid token:(NSString *)token index:(NSInteger)index pages:(NSArray<NSString *> *)pages {
    CBLDocument *document = [[self galleries] createDocument];
    CBLJSONDict *properties = @{ @"gid": gid, @"token": token, @"index": @(index), @"pages": pages };
    [document putProperties:properties error:nil];
}

+ (NSArray<NSString *> *)galleryBy:(NSString *)gid token:(NSString *)token index:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%@-%@-%ld", gid, token, index];
    CBLQuery *query = [[[self galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error || results.count == 0) {
        return nil;
    }
    else {
        NSLog(@"Found Gallery Pages : %@, %@, %ld", gid, token, index);
        return [results rowAtIndex:0].document.properties[@"pages"];
    }
}

#pragma mark * Search

+ (SearchInfo *)searchInfo {
    CBLQuery *query = [[self search] createAllDocumentsQuery];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    
    if (error || results.count == 0) {
        return [SearchInfo new];
    }
    else {
        return [[SearchInfo alloc] initWithDictionary:[results rowAtIndex:0].document.properties];
    }
}

+ (void)setSearchInfo:(SearchInfo *)searchInfo {
    CBLQuery *query = [[self search] createAllDocumentsQuery];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    
    if (error) {
        NSLog(@"SetSearchInfo Fail");
    }
    else {
        if (results.count == 0) {
            CBLDocument *document = [[self search] createDocument];
            CBLJSONDict *properties = [searchInfo storeContents];
            [document putProperties:properties error:nil];
        }
        else {
            CBLDocument *document = [results rowAtIndex:0].document;
            [document update: ^BOOL(CBLUnsavedRevision *newRev) {
                NSDictionary *storeContents = [searchInfo storeContents];
                for (NSString *key in storeContents.allKeys) {
                    newRev[key] = storeContents[key];
                }
                return YES;
            } error:nil];
        }
    }
}

#pragma mark * Histories

+ (NSInteger)fetchUserLatestPage:(HentaiInfo *)hentaiInfo {
    NSString *key = [NSString stringWithFormat:@"%@-%@", hentaiInfo.gid, hentaiInfo.token];
    CBLQuery *query = [[[self histories] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"fetchUserLatestPage Fail");
        return 0;
    }
    else {
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
        }
        else {
            CBLDocument *document = [[self histories] createDocument];
            hentaiInfo.timeStamp = @([[NSDate date] timeIntervalSince1970]);
            [document putProperties:[hentaiInfo storeContents] error:nil];
        }
        return userLatestPage;
    }
}

+ (void)updateUserLatestPage:(HentaiInfo *)hentaiInfo userLatestPage:(NSInteger)userLatestPage {
    NSString *key = [NSString stringWithFormat:@"%@-%@", hentaiInfo.gid, hentaiInfo.token];
    CBLQuery *query = [[[self histories] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"updateUserLatestPage Fail");
    }
    else {
        if (results.count) {
            CBLDocument *document = [results rowAtIndex:0].document;
            [document update: ^BOOL(CBLUnsavedRevision *rev) {
                rev[@"userLatestPage"] = @(userLatestPage);
                return YES;
            } error:nil];
        }
    }
}

+ (NSArray<NSDictionary *> *)historiesFrom:(NSInteger)start length:(NSInteger)length {
    CBLQuery *query = [[[self histories] viewNamed:@"sort"] createQuery];
    query.skip = start;
    query.limit = length;
    query.descending = YES;
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"historiesFrom Fail");
        return nil;
    }
    else {
        if (results.count == 0) {
            return nil;
        }
        else {
            NSMutableArray *histories = [NSMutableArray array];
            for (NSInteger index = 0; index < results.count; index++) {
                NSDictionary *properties = [results rowAtIndex:index].document.properties;
                HentaiInfo *info = [HentaiInfo new];
                [info restoreContents:[NSMutableDictionary dictionaryWithDictionary:properties] defaultContent:nil];
                [histories addObject:info];
            }
            return histories;
        }
    }
}

+ (void)deleteAllHistories:(void (^)(NSInteger total, NSInteger index, HentaiInfo *info))handler onFinish:(void (^)(BOOL successed))finish {
    CBLQuery *query = [[self histories] createAllDocumentsQuery];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"allHistories Fail");
        if (finish) {
            finish(NO);
        }
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSInteger index = 0; index < results.count; index++) {
                __block CBLDocument *document = nil;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    document = [results rowAtIndex:index].document;
                });
                if (!document) {
                    continue;
                }
                
                NSDictionary *properties = document.properties;
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
}

@end
