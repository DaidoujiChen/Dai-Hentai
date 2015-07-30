//
//  MenuViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate;

@interface MenuViewController : ColorThemeViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;

@end

@protocol MenuViewControllerDelegate <NSObject>

@required
- (void)needToChangeViewController:(NSString *)className;

@end
