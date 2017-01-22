//
//  HentaiWatching.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2017/1/22.
//  Copyright © 2017年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HentaiWatching : NSObject

+ (BOOL)inCache:(NSString *)hentaiKey;
+ (void)startOn:(NSString *)hentaiKey;
+ (void)stopOn:(NSString *)hentaiKey;

@end
