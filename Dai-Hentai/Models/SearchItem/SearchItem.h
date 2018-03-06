//
//  SearchItem.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/24.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchItem : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) SEL getterSEL;
@property (nonatomic, readonly) SEL setterSEL;

+ (instancetype)itemWith:(NSString *)title getter:(NSString *)getter;

@end
