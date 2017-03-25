//
//  NSTimer+Block.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/25.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "NSTimer+Block.h"

@implementation NSTimer (Block)

#pragma mark - Private Class Method

+ (void)invokeBlock:(NSTimer *)timer {
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}

#pragma mark - Class Method

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats usingBlock:(void (^)(void))block {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(invokeBlock:) userInfo:[block copy] repeats:repeats];
}

@end
