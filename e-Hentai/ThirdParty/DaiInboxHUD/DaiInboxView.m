//
//  DaiInboxView.m
//  DaiInboxHUD
//
//  Created by 啟倫 陳 on 2014/10/31.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiInboxView.h"

#import <objc/runtime.h>

#define degreesToRadian(angle) (M_PI * (angle) / 180.0)

//控制最大最小長度, 以及每次迭代長度
#define maxLength 200.0f
#define minLength 2.0f
#define lengthIteration 8.0f

//每次旋轉角度
#define rotateIteration 4.0f

//動畫的 fps 設定, 以及最長最短時要停留的 frame 張數
#define framePerSecond 60.0f
#define maxWaitingFrame 30.0f

typedef enum {
    CricleLengthStatusDecrease,
    CricleLengthStatusIncrease,
    CricleLengthStatusWaiting
} CricleLengthStatus;

@interface UIColor (MixColor)

@property (nonatomic, readonly) CGFloat r;
@property (nonatomic, readonly) CGFloat g;
@property (nonatomic, readonly) CGFloat b;
@property (nonatomic, readonly) CGFloat a;

- (UIColor *)mixColor:(UIColor *)otherColor;

@end

@implementation UIColor (MixColor)

@dynamic r, g, b, a;

- (CGFloat)r {
    return [[self rgba][@"r"] floatValue];
}

- (CGFloat)g {
    return [[self rgba][@"g"] floatValue];
}

- (CGFloat)b {
    return [[self rgba][@"b"] floatValue];
}

- (CGFloat)a {
    return [[self rgba][@"a"] floatValue];
}

- (UIColor *)mixColor:(UIColor *)otherColor {
    //混色的公式
    //http://stackoverflow.com/questions/726549/algorithm-for-additive-color-mixing-for-rgb-values
    CGFloat newAlpha = 1 - (1 - self.a) * (1 - otherColor.a);
    CGFloat newRed = self.r * self.a / newAlpha + otherColor.r * otherColor.a * (1 - self.a) / newAlpha;
    CGFloat newGreen = self.g * self.a / newAlpha + otherColor.g * otherColor.a * (1 - self.a) / newAlpha;
    CGFloat newBlue = self.b * self.a / newAlpha + otherColor.b * otherColor.a * (1 - self.a) / newAlpha;
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

- (NSDictionary *)rgba {
    NSDictionary *rgba = objc_getAssociatedObject(self, _cmd);
    if (!rgba) {
        CGFloat red = 0.0f, green = 0.0f, blue = 0.0f, alpha = 0.0f;
        if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
            [self setRgba:@{ @"r":@(red), @"g":@(green), @"b":@(blue), @"a":@(alpha) }];
        }
        else {
            //http://stackoverflow.com/questions/4700168/get-rgb-value-from-uicolor-presets
            CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            unsigned char resultingPixel[3];
            CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNone);
            CGContextSetFillColorWithColor(context, [self CGColor]);
            CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
            CGContextRelease(context);
            CGColorSpaceRelease(rgbColorSpace);
            [self setRgba:@{ @"r":@(resultingPixel[0]), @"g":@(resultingPixel[1]), @"b":@(resultingPixel[2]), @"a":@(1.0f) }];
        }
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRgba:(NSDictionary *)rgba {
    objc_setAssociatedObject(self, @selector(rgba), rgba, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface DaiInboxView ()

//當前長度, 旋轉角度, 狀態
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger rotateAngle;
@property (nonatomic, assign) CricleLengthStatus status;

//變換的顏色, default 是 紅 -> 綠 -> 黃 -> 藍, 以及當前在哪一個顏色上
@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, strong) UIColor *finalColor;
@property (nonatomic, strong) UIColor *prevColor;
@property (nonatomic, strong) UIColor *gradualColor;

//已等待張數
@property (nonatomic, assign) NSInteger waitingFrameCount;

//固定的中心點及半徑, 不需每次計算
@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat circleRadius;

@end

@implementation DaiInboxView

#pragma mark - private

//每 frame 所做的數值變動
- (void)refreshCricle {
    //為了不阻礙線程, 一部份的運算放到 background 做
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        switch (self.status) {
            case CricleLengthStatusDecrease:
            {
                self.length -= lengthIteration;
                self.rotateAngle += rotateIteration;
                
                //當長度扣到過短時, 讓他停下來, 設定好顏色, 準備另一個階段
                if (self.length <= minLength) {
                    self.length = minLength;
                    self.status = CricleLengthStatusWaiting;
                    self.colorIndex++;
                    self.colorIndex %= [self.hudColors count];
                    self.prevColor = self.finalColor;
                    self.finalColor = self.hudColors[self.colorIndex];
                }
                break;
            }
                
            case CricleLengthStatusIncrease:
            {
                self.length += lengthIteration;
                CGFloat deltaLength = sin(((float)lengthIteration / 360) * M_PI_2) * 360;
                self.rotateAngle += (rotateIteration + deltaLength);
                
                //長度過長時, 讓他停下來, 準備去另一個階段
                if (self.length >= maxLength) {
                    self.length = maxLength;
                    self.status = CricleLengthStatusWaiting;
                }
                break;
            }
                
            case CricleLengthStatusWaiting:
            {
                self.waitingFrameCount++;
                self.rotateAngle += rotateIteration;
                
                //這個狀態下需要多算一個漸變色
                if (self.length == minLength) {
                    CGFloat colorAPercent = ((float)self.waitingFrameCount / maxWaitingFrame);
                    CGFloat colorBPercent = 1 - colorAPercent;
                    UIColor *transparentColorA = [UIColor colorWithRed:self.finalColor.r green:self.finalColor.g blue:self.finalColor.b alpha:colorAPercent];
                    UIColor *transparentColorB = [UIColor colorWithRed:self.prevColor.r green:self.prevColor.g blue:self.prevColor.b alpha:colorBPercent];
                    self.gradualColor = [transparentColorA mixColor:transparentColorB];
                }
                
                //當幀數到達指定的數量, 按照他的狀態, 分配他該去的狀態
                if (self.waitingFrameCount == maxWaitingFrame) {
                    self.waitingFrameCount = 0;
                    if (self.length == minLength) {
                        self.status = CricleLengthStatusIncrease;
                    }
                    else {
                        self.status = CricleLengthStatusDecrease;
                    }
                }
                break;
            }
        }
        self.rotateAngle %= 360;
        
        //算完以後回 main thread 囉
        dispatch_async(dispatch_get_main_queue(), ^{
            self.transform = CGAffineTransformMakeRotation(degreesToRadian(self.rotateAngle));
            [self setNeedsDisplay];
        });
    });
}

#pragma mark - method override

//這邊主要就只負責把圖畫出來
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //設定線條的粗細, 以及圓角
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.hudLineWidth);
    
    //設定線條的顏色, 只有在最短狀態的時候才需要用漸變色
    if (self.status == CricleLengthStatusWaiting && self.length == minLength) {
        CGContextSetRGBStrokeColor(context, self.gradualColor.r, self.gradualColor.g, self.gradualColor.b, self.gradualColor.a);
    }
    else {
        CGContextSetRGBStrokeColor(context, self.finalColor.r, self.finalColor.g, self.finalColor.b, self.finalColor.a);
    }
    
    //設定半弧的中心, 半徑, 起始以及終點
    CGFloat deltaLength = sin(((float)self.length / 360) * M_PI_2) * 360;
    CGFloat startAngle = degreesToRadian(-deltaLength);
    CGContextAddArc(context, self.circleCenter.x, self.circleCenter.y, self.circleRadius, startAngle, 0, 0);
    
    //著色
    CGContextStrokePath(context);
    
    //這邊改成用 afterDelay 的做法而不用 nstimer, 因為我怕有時候畫的時間因為各種原因過長, 如果只卡固定的 fps, 反而會降低 app 本身其他東西的效能
    [self performSelector:@selector(refreshCricle) withObject:nil afterDelay:1.0f / framePerSecond];
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始值
        self.backgroundColor = [UIColor clearColor];
        self.rotateAngle = arc4random() % 360;
        self.length = maxLength;
        self.status = CricleLengthStatusDecrease;
        self.waitingFrameCount = 0;
        self.circleCenter = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        self.circleRadius = frame.size.width / 3;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    //從 newSuperview 的有無可以判斷現在是被加入或是被移除
    if (newSuperview) {
        self.colorIndex = arc4random() % [self.hudColors count];
        self.finalColor = self.hudColors[self.colorIndex];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshCricle) object:nil];
    }
}

@end
