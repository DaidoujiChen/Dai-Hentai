//
//  SettingViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColorThemeViewController.h"

@interface SettingViewController : ColorThemeViewController <GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet UILabel *gPlusConnectLabel;
@property (weak, nonatomic) IBOutlet GPPSignInButton *gPlusSignInButton;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedSizeLabel;

@end
