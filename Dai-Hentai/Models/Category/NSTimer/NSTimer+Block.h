//
//  NSTimer+Block.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/25.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Block)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats usingBlock:(void (^)(void))block;

@end
