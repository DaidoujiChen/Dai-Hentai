//
//  DBSearchSetting.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "DBSearchSetting.h"
#import <objc/runtime.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLDatabase+RefreshView.h"

@implementation DBSearchSetting

#pragma mark - Private Class Method

+ (CBLDatabase *)search {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CBLManager *manager = [CBLManager sharedInstance];
        NSError *error;
        CBLDatabase *db = [manager databaseNamed:@"search" error:&error];
        if (error) {
            NSLog(@"DB init error : %@", error);
            return;
        }
        
        objc_setAssociatedObject(self, _cmd, db, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Class Method

+ (SearchInfo *)info {
    CBLQuery *query = [[self search] createAllDocumentsQuery];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    
    if (error || results.count == 0) {
        return [SearchInfo new];
    }
    
    return [[SearchInfo alloc] initWithDictionary:[results rowAtIndex:0].document.properties];
}

+ (void)setInfo:(SearchInfo *)info {
    CBLQuery *query = [[self search] createAllDocumentsQuery];
    NSError *error;
    CBLQueryEnumerator *results = [query run:&error];
    
    if (error) {
        NSLog(@"SetSearchInfo Fail");
        return;
    }
    
    if (results.count == 0) {
        CBLDocument *document = [[self search] createDocument];
        CBLJSONDict *properties = [info storeContents];
        [document putProperties:properties error:nil];
        return;
    }
    
    CBLDocument *document = [results rowAtIndex:0].document;
    [document update: ^BOOL(CBLUnsavedRevision *newRev) {
        NSDictionary *storeContents = [info storeContents];
        for (NSString *key in storeContents.allKeys) {
            newRev[key] = storeContents[key];
        }
        return YES;
    } error:nil];
}

@end
