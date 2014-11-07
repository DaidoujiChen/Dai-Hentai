//
//  DaiInboxDisplayLink.m
//  DaiInboxHUD
//
//  Created by 啟倫 陳 on 2014/11/7.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiInboxDisplayLink.h"

@interface DaiInboxDisplayLink ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL nextDeltaTimeZero;
@property (nonatomic, assign) CFTimeInterval previousTimestamp;

@end

@implementation DaiInboxDisplayLink

#pragma mark - instance method

- (void)removeDisplayLink {
    //移除 displaylink
    [self.displayLink invalidate];
    
    //移除掉監聽
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - private

- (void)setupDisplayLink {
    //建立 displaylink
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdated)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    //監聽兩個 notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
}

//當畫面的 frame 有變動時, 會進到這個地方
- (void)displayLinkUpdated {
    //用時間戳記算出兩個 frame 的間隔時間
    CFTimeInterval currentTime = self.displayLink.timestamp;
    CFTimeInterval deltaTime;
    if (self.nextDeltaTimeZero) {
        self.nextDeltaTimeZero = NO;
        deltaTime = 0.0;
    }
    else {
        deltaTime = currentTime - self.previousTimestamp;
    }
    self.previousTimestamp = currentTime;
    
    //把這個數值用 delegate 帶回去
    [self.delegate displayWillUpdateWithDeltaTime:deltaTime];
}

//如果 app 要回來前景了, displaylink 則啟動
- (void)applicationDidBecomeActiveNotification {
    self.displayLink.paused = NO;
    self.nextDeltaTimeZero = YES;
}

//反之則暫停
- (void)applicationWillResignActiveNotification {
    self.displayLink.paused = YES;
    self.nextDeltaTimeZero = YES;
}

#pragma mark - life cycle

- (id)initWithDelegate:(id <DaiInboxDisplayLinkDelegate> )delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.nextDeltaTimeZero = YES;
        self.previousTimestamp = 0;
        [self setupDisplayLink];
    }
    return self;
}

@end
