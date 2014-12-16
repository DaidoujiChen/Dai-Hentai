//
//  DiveExHentai.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/15.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DiveExHentai : NSObject

+ (void)diveByUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(BOOL isSuccess))completion;

@end
