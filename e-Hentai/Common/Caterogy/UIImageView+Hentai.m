//
//  UIImageView+Hentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/5.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "UIImageView+Hentai.h"

@implementation UIImageView (Hentai)

//設定圖片後加個模糊遮照
- (void)hentai_blurWithImage:(UIImage *)image {
    self.image = image;
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:self.bounds];
    blurView.blurRadius = 15.0f;
    blurView.dynamic = NO;
    [self addSubview:blurView];
}

- (void)hentai_pathShadow {
    float widthRatio = self.bounds.size.width / self.image.size.width;
    float heightRatio = self.bounds.size.height / self.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * self.image.size.width;
    float imageHeight = scale * self.image.size.height;
    
    CGRect centerFrame = CGRectMake(self.bounds.size.width / 2 - imageWidth / 2, self.bounds.size.height / 2 - imageHeight / 2, imageWidth, imageHeight);
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:centerFrame];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowPath = shadowPath.CGPath;
}

@end
