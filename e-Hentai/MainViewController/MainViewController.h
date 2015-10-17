//
//  MainViewController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchFilterV2ViewController.h"
#import "MainTableViewCell.h"
#import "PhotoViewController.h"

@protocol MainViewControllerDelegate;

@interface MainViewController : ColorThemeViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchFilterV2ViewControllerDelegate>

@property (nonatomic, weak) id <MainViewControllerDelegate, OpenMenuProtocol> delegate;

@end

@protocol MainViewControllerDelegate <NSObject>

@required
- (void)needToPushViewController:(UIViewController *)controller;

@end
