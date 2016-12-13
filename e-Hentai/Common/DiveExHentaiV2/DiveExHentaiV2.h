//
//  DiveExHentaiV2.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2016/11/28.
//  Copyright © 2016年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiveExHentaiV2 : NSObject

+ (void)replaceCookies;
+ (BOOL)checkCookie;
+ (void)diveBy:(NSString *)username andPassword:(NSString *)password completion:(void (^)(BOOL isSuccess))completion;

@end
