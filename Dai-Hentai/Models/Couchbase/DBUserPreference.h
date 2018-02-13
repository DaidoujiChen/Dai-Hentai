//
//  DBUserPreference.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/2/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPreference.h"

@interface DBUserPreference : NSObject

+ (UserPreference *)info;
+ (void)setInfo:(UserPreference *)info;

@end
