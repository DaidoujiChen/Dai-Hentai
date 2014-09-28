//
//  HentaiSearchFilter.h
//  CoreGraphicsTest
//
//  Created by OptimusKe on 2014/9/26.
//  Copyright (c) 2014年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HentaiFilterType) {
    HentaiFilterTypeDoujinshi = 0,
    HentaiFilterTypeManga,
    HentaiFilterTypeArtistcg,
    HentaiFilterTypeGamecg,
    HentaiFilterTypeWestern,
    HentaiFilterTypeNonh,
    HentaiFilterTypeImagesets,
    HentaiFilterTypeCosplay,
    HentaiFilterTypeAsianporn,
    HentaiFilterTypeMisc
};

@interface HentaiSearchFilter : NSObject

+ (NSString*)searchFilterUrlByKeyword:(NSString*)searchWord
                          filterArray:(NSArray*)filterArray
                              baseUrl:(NSString*)baseUrl;

@end
