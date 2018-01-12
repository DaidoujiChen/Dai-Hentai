//
//  DBGalleryPage.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "DBGalleryPage.h"
#import <objc/runtime.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLDatabase+RefreshView.h"

@implementation DBGalleryPage

#pragma mark - Private Class Method

+ (CBLDatabase *)galleries {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"galleries" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
            return;
        }
        
        CBLView *view = [db refreshViewNamed:@"query"];
        [view setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
            NSString *key = [NSString stringWithFormat:@"%@-%@-%@", doc[@"gid"], doc[@"token"], doc[@"index"]];
            emit(key, nil);
        } version:@"1"];
        objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Class Method

+ (void)add:(NSString *)gid token:(NSString *)token index:(NSInteger)index pages:(NSArray<NSString *> *)pages {
    CBLDocument *document = [[self galleries] createDocument];
    CBLJSONDict *properties = @{ @"gid": gid, @"token": token, @"index": @(index), @"pages": pages };
    [document putProperties:properties error:nil];
}

+ (NSArray<NSString *> *)by:(NSString *)gid token:(NSString *)token index:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%@-%@-%@", gid, token, @(index)];
    CBLQuery *query = [[[self galleries] viewNamed:@"query"] createQuery];
    query.keys = @[ key ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error || results.count == 0) {
        return nil;
    }
    
    NSLog(@"Found Gallery Pages : %@, %@, %@", gid, token, @(index));
    return [results rowAtIndex:0].document.properties[@"pages"];
}

@end
