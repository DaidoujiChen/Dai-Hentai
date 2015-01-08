//
//  HentaiSettingManager.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/7.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "HentaiSettingManager.h"

@implementation HentaiSettingManager

+ (void)settingTransfer {
    if ([[FilesManager documentFolder] read:@"HentaiSettings.plist"].length) {
        [LightWeightPlist lwpSafe:^{
            NSDictionary *oldSettings = LWPDictionary(@"HentaiSettings");
            [self setIsHighResolution:[oldSettings[@"highResolution"] boolValue]];
            [self setIsUseNewBrowser:[oldSettings[@"useNewBroswer"] boolValue]];
            LWPDelete(@"HentaiSettings");
        }];
    }
}

+ (BOOL)isHighResolution {
    if (!HentaiSettingsV2[@"highResolution"]) {
        [self setIsHighResolution:NO];
    }
    NSNumber *isHighResolution = HentaiSettingsV2[@"highResolution"];
    return [isHighResolution boolValue];
}

+ (void)setIsHighResolution:(BOOL)isHighResolution {
    [LightWeightPlist lwpSafe:^{
        HentaiSettingsV2[@"highResolution"] = @(isHighResolution);
        LWPForceWrite();
    }];
}

+ (BOOL)isUseNewBrowser {
    if (!HentaiSettingsV2[@"useNewBrowser"]) {
        [self setIsHighResolution:NO];
    }
    NSNumber *isUseNewBrowser = HentaiSettingsV2[@"useNewBrowser"];
    return [isUseNewBrowser boolValue];
}

+ (void)setIsUseNewBrowser:(BOOL)isUseNewBrowser {
    [LightWeightPlist lwpSafe:^{
        HentaiSettingsV2[@"useNewBrowser"] = @(isUseNewBrowser);
        LWPForceWrite();
    }];
}

+ (NSString *)themeColorString {
    if (!HentaiSettingsV2[@"themeColor"]) {
        [self setThemeColorString:@"flatPinkColor"];
    }
    return HentaiSettingsV2[@"themeColor"];
}

+ (void)setThemeColorString:(NSString *)themeColorString {
    [LightWeightPlist lwpSafe:^{
        HentaiSettingsV2[@"themeColor"] = themeColorString;
        LWPForceWrite();
    }];
}

@end
