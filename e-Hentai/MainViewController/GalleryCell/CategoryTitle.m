//
//  CategoryTitle.m
//  e-Hentai
//
//  Created by Jack on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "CategoryTitle.h"

//Flat Blue
#define CORLOR_TEXT  [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1]

@implementation CategoryTitle


- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        categoryString = @"";
        categoryLabel = [UILabel new];
        [self addSubview:categoryLabel];
    }
    return self;
}

- (void)setCategoryStr:(NSString*)category
{
    categoryString = category;
    [self layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)layoutSubviews
{
    
    CGRect labelFrame = CGRectOffset(self.bounds, 5, 0); //padding 5
    categoryLabel.frame = labelFrame;
    [categoryLabel setBackgroundColor:[UIColor clearColor]];
    [categoryLabel setTextColor:CORLOR_TEXT];
    categoryLabel.font = [UIFont systemFontOfSize:14.0];
    categoryLabel.text = categoryString;
    
    [self.layer setCornerRadius:CGRectGetHeight(self.bounds) / 4];
}

@end
