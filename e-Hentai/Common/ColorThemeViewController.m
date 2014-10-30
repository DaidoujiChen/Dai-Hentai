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
    
    NSArray *colorFriends = [NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous for:[UIColor flatGreenColor] flatScheme:YES];
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.bounds andColors:@[colorFriends[0], colorFriends[4]]];
}

@end
