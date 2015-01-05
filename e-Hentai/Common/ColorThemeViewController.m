//
//  ColorThemeViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/30.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "ColorThemeViewController.h"

@interface ColorThemeViewController ()

@end

@implementation ColorThemeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *colorFriends = [NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous for:[UIColor flatPinkColor] flatScheme:YES];
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.bounds andColors:@[colorFriends[0], colorFriends[4]]];
}

//本來 settitle 是設定 navigation title 上面的字, 這邊把他轉換成用漂亮的字體秀
- (void)setTitle:(NSString *)title {
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UIColor *textColor = [UIColor flatBlackColor];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : textColor, NSFontAttributeName : font, NSTextEffectAttributeName : NSTextEffectLetterpressStyle };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = attributedString;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

@end
