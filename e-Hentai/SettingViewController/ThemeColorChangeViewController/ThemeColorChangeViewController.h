//
//  ThemeColorChangeViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/7.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorThemeViewController.h"

@protocol ThemeColorChangeViewControllerDelegate;

@interface ThemeColorChangeViewController : ColorThemeViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <ThemeColorChangeViewControllerDelegate> delegate;

@end

@protocol ThemeColorChangeViewControllerDelegate <NSObject>

@required
- (void)themeColorDidChange;

@end
