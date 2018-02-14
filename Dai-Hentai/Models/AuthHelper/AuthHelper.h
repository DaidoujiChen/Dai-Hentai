//
//  AuthHelper.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/2/13.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthHelper : NSObject

+ (void)refreshAuth;
+ (BOOL)canLock;
+ (void)checkFor:(NSString *)reason completion:(void (^)(BOOL pass))completion;

@end
