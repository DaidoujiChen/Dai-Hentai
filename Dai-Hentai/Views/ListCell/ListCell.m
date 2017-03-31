//
//  ListCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

- (void)simpleShadowOn:(UIView *)view opacity:(CGFloat)opacity radius:(CGFloat)radius {
    view.layer.masksToBounds = NO;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.title.preferredMaxLayoutWidth = self.title.bounds.size.width;
    
    [self simpleShadowOn:self opacity:0.5f radius:2.0f];
    [self simpleShadowOn:self.thumbImageView opacity:0.125f radius:0.5f];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbImageView.image = nil;
}

@end
