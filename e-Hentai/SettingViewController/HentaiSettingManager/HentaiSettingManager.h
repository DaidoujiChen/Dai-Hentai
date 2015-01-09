//
//  HentaiSettingManager.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/7.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HentaiSettingManager : NSObject

+ (void)settingTransfer;

+ (NSArray *)staticMenuItems;
+ (NSArray *)staticFilters;

+ (void)storeHentaiPrefer;
+ (NSMutableDictionary *)temporaryHentaiPrefer;

+ (void)storeHentaiAccount;
+ (NSMutableDictionary *)temporaryHentaiAccount;

+ (void)storeSettings;
+ (NSMutableDictionary *)temporarySettings;

@end
