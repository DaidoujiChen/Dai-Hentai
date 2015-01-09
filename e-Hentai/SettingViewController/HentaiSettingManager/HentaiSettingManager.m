//
//  HentaiSettingManager.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/7.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "HentaiSettingManager.h"

#import <objc/runtime.h>

@implementation HentaiSettingManager

+ (void)settingTransfer {
    if ([[FilesManager documentFolder] read:@"HentaiSettings.plist"].length) {
        [LightWeightPlist lwpSafe:^{
            NSDictionary *oldSettings = LWPDictionary(@"HentaiSettings");
            [self temporarySettings][@"highResolution"] = oldSettings[@"highResolution"];
            [self temporarySettings][@"useNewBrowser"] = oldSettings[@"useNewBroswer"];
            [LWPDictionary(@"HentaiSettingsV2") setDictionary:[self temporarySettings]];
            LWPForceWriteSpecific(@"HentaiSettingsV2");
            LWPDelete(@"HentaiSettings");
        }];
    }
}

+ (NSArray *)staticMenuItems {
    static NSArray *staticMenuItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticMenuItems = [[NSArray alloc] initWithArray:LWPArrayR(@"Menu")];
    });
    return staticMenuItems;
}

+ (NSArray *)staticFilters {
    static NSArray *staticFilters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticFilters = [[NSArray alloc] initWithArray:LWPArrayR(@"HentaiFilters")];
    });
    return staticFilters;
}

+ (void)storeHentaiPrefer {
    [LightWeightPlist lwpSafe:^{
        [LWPDictionary(@"HentaiPrefer") setDictionary:[self temporaryHentaiPrefer]];
        LWPForceWriteSpecific(@"HentaiPrefer");
    }];
}

+ (NSMutableDictionary *)temporaryHentaiPrefer {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, LWPDictionary(@"HentaiPrefer"), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)storeHentaiAccount {
    [LightWeightPlist lwpSafe:^{
        [LWPDictionary(@"HentaiAccount") setDictionary:[self temporaryHentaiAccount]];
        LWPForceWriteSpecific(@"HentaiAccount");
    }];
}

+ (NSMutableDictionary *)temporaryHentaiAccount {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, LWPDictionary(@"HentaiAccount"), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)storeSettings {
    [LightWeightPlist lwpSafe:^{
        [LWPDictionary(@"HentaiSettingsV2") setDictionary:[self temporarySettings]];
        LWPForceWriteSpecific(@"HentaiSettingsV2");
    }];
}

+ (NSMutableDictionary *)temporarySettings {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, LWPDictionary(@"HentaiSettingsV2"), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

@end
