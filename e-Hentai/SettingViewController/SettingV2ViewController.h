//
//  SettingV2ViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/3.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "QuickDialogController.h"

#import "HentaiNavigationController.h"
#import "ThemeColorChangeViewController.h"

@interface SettingV2ViewController : QuickDialogController <ThemeColorChangeViewControllerDelegate>

@property (nonatomic, weak) id <OpenMenuProtocol> delegate;

@end
