//
//  HentaiSearchFilter.m
//  CoreGraphicsTest
//
//  Created by OptimusKe on 2014/9/26.
//  Copyright (c) 2014年 Jack. All rights reserved.
//

#import "HentaiSearchFilter.h"

//Fillter 全開
//http://g.e-hentai.org/?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=1&f_non-h=1&f_imageset=1&f_cosplay=1&f_asianporn=1&f_misc=1&f_search=Search+Keywords&f_apply=Apply+Filter

#define doujinshiFilter    @"f_doujinshi=1"
#define mangaFilter        @"f_manga=1"
#define artistcgFilter     @"f_artistcg=1"
#define gamecgFilter       @"f_gamecg=1"
#define westernFilter      @"f_western=1"
#define nonhFilter         @"f_non-h=1"
#define imagesetFilter     @"f_imageset=1"
#define cosplayFilter      @"f_cosplay=1"
#define asianpornFilter    @"f_asianporn=1"
#define miscFilter         @"f_misc=1"



@implementation HentaiSearchFilter

+ (NSString*)searchFilterUrlByKeyword:(NSString*)searchWord
                          filterArray:(NSArray*)filterArray
                              baseUrl:(NSString*)baseUrl
{
    
    NSString* filterUrl = [[NSString alloc] initWithString:baseUrl];
    
    //do nothing
    if([searchWord isEqualToString:@""] && filterArray.count == 0){
        return filterUrl;
    }
    
    
    NSDictionary* filterMapping = @{ @(HentaiFilterTypeDoujinshi)  : doujinshiFilter,
                                     @(HentaiFilterTypeManga)      : mangaFilter,
                                     @(HentaiFilterTypeArtistcg)   : artistcgFilter,
                                     @(HentaiFilterTypeGamecg)     : gamecgFilter,
                                     @(HentaiFilterTypeWestern)    : westernFilter,
                                     @(HentaiFilterTypeNonh)       : nonhFilter,
                                     @(HentaiFilterTypeImagesets)  : imagesetFilter,
                                     @(HentaiFilterTypeCosplay)    : cosplayFilter,
                                     @(HentaiFilterTypeAsianporn)  : asianpornFilter,
                                     @(HentaiFilterTypeMisc)       : miscFilter};
   
    if(filterArray.count != 0 || filterArray.count != 10){
        for(NSNumber* filterNum in filterArray){
            filterUrl = [filterUrl stringByAppendingString:[NSString stringWithFormat:@"&%@",filterMapping[filterNum]]];
        }
    }
    
    if(![searchWord isEqualToString:@""]){
        filterUrl = [filterUrl stringByAppendingString:[NSString stringWithFormat:@"&f_search=%@",searchWord]];
    }
    
    //apply
    filterUrl = [filterUrl stringByAppendingString:@"&f_apply=Apply+Filter"];
    
    return filterUrl;
}


@end
