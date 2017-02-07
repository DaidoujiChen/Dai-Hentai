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

+ (void)tryCreate {
    CBLDocument *document = [[self db] createDocument];
    NSError *error;
    CBLJSONDict *properties = @{ @"number": @(arc4random() % 100), @"number2": @(arc4random() % 100 + 100) };
    [document putProperties:properties error:&error];
}

+ (void)tryQuery {
    CBLQuery *query = [[[self db] viewNamed:@"hello"] createQuery];
    query.keys = @[ @(49) ];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    if (error) {
        NSLog(@"===== %@", error);
    }
    else {
        for (NSInteger index = 0; index < results.count; index++) {
            NSLog(@"===== %@", [[results rowAtIndex:index] document].properties);
        }
    }
}

+ (CBLDatabase *)db {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"hentai" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
        }
        else {
            
            CBLView *view = [db viewNamed:@"hello"];
            [view setMapBlock: ^(CBLJSONDict *doc, CBLMapEmitBlock emit) {
                emit(doc[@"number"], nil);
            } version:@"1"];
            
            objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    return objc_getAssociatedObject(self, _cmd);
}

@end
