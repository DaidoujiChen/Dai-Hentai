//
//  Couchbase.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/10.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "Couchbase.h"
#import <objc/runtime.h>

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

@end
