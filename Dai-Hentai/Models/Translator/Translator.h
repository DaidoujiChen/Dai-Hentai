//
//  Translator.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Translator : NSObject

+ (NSString *)remove:(NSString *)text;
+ (NSString *)from:(NSString *)eng;

@end
