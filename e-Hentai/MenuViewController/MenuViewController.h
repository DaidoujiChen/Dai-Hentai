//
//  MenuViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuDefaultCell.h"

@protocol MenuViewControllerDelegate;

@interface MenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@end

@protocol MenuViewControllerDelegate <NSObject>

@required
- (void)needToChangeViewController:(NSString *)className;

@end
