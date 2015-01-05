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

@end
