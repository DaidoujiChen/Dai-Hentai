//
//  DBGalleryPage.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBGalleryPage : NSObject

+ (void)add:(NSString *)gid token:(NSString *)token index:(NSInteger)index pages:(NSArray<NSString *> *)pages;
+ (NSArray<NSString *> *)by:(NSString *)gid token:(NSString *)token index:(NSInteger)index;

@end
