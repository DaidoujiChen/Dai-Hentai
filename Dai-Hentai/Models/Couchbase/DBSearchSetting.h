//
//  DBSearchSetting.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchInfo.h"

@interface DBSearchSetting : NSObject

+ (SearchInfo *)info;
+ (void)setInfo:(SearchInfo *)info;

@end
