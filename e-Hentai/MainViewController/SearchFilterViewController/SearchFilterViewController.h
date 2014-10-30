//
//  SearchFilterViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColorThemeViewController.h"
#import "MenuDefaultCell.h"

@protocol SearchFilterViewControllerDelegate;

@interface SearchFilterViewController : ColorThemeViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, weak) id <SearchFilterViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;

@end

@protocol SearchFilterViewControllerDelegate <NSObject>

@required
- (void)onSearchFilterDone;

@end
