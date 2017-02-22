//
//  Couchbase.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/10.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "SearchInfo.h"

@interface Couchbase : NSObject

+ (void)addGalleryBy:(NSString *)gid token:(NSString *)token index:(NSInteger)index pages:(NSArray<NSString *> *)pages;
+ (NSArray<NSString *> *)galleryBy:(NSString *)gid token:(NSString *)token index:(NSInteger)index;

+ (SearchInfo *)searchInfo;
+ (void)setSearchInfo:(SearchInfo *)searchInfo;

@end
