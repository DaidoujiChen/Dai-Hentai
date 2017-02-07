//
//  ListCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.title.preferredMaxLayoutWidth = self.title.bounds.size.width;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbImageView.image = nil;
}

@end
