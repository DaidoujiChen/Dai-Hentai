//
//  HentaiSearchFilter.m
//  CoreGraphicsTest
//
//  Created by OptimusKe on 2014/9/26.
//  Copyright (c) 2014年 Jack. All rights reserved.
//

#import "HentaiSearchFilter.h"

@implementation HentaiSearchFilter

+ (NSString *)searchFilterUrlByKeyword:(NSString *)searchWord
                           filterArray:(NSArray *)filterArray
                               baseUrl:(NSString *)baseUrl {
	NSString *filterUrl = [[NSString alloc] initWithString:baseUrl];
    
	//do nothing
	if ([searchWord isEqualToString:@""] && filterArray.count == 0) {
		return filterUrl;
	}
    
    
	NSDictionary *filterMapping = @{ @(HentaiFilterTypeDoujinshi)  : @"f_doujinshi=1",
		                             @(HentaiFilterTypeManga)      : @"f_manga=1",
		                             @(HentaiFilterTypeArtistcg)   : @"f_artistcg=1",
		                             @(HentaiFilterTypeGamecg)     : @"f_gamecg=1",
		                             @(HentaiFilterTypeWestern)    : @"f_western=1",
		                             @(HentaiFilterTypeNonh)       : @"f_non-h=1",
		                             @(HentaiFilterTypeImagesets)  : @"f_imageset=1",
		                             @(HentaiFilterTypeCosplay)    : @"f_cosplay=1",
		                             @(HentaiFilterTypeAsianporn)  : @"f_asianporn=1",
		                             @(HentaiFilterTypeMisc)       : @"f_misc=1" };
    
	if (filterArray.count != 0 || filterArray.count != 10) {
		for (NSNumber *filterNum in filterArray) {
			filterUrl = [filterUrl stringByAppendingString:[NSString stringWithFormat:@"&%@", filterMapping[filterNum]]];
		}
	}
    
	if (![searchWord isEqualToString:@""]) {
		filterUrl = [filterUrl stringByAppendingString:[NSString stringWithFormat:@"&f_search=%@", searchWord]];
	}
    
	//apply
	filterUrl = [filterUrl stringByAppendingString:@"&f_apply=Apply+Filter"];
    
	return filterUrl;
}

@end
