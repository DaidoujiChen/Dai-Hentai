//
//  UIView+Hentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/5.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "UIView+Hentai.h"

@implementation UIView (Hentai)

//用 UIBezierPath 的 shadow, 比較快
- (void)hentai_pathShadow {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowPath = shadowPath.CGPath;
}

@end
