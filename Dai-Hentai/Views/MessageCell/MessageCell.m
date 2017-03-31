//
//  MessageCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/31.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

@end
