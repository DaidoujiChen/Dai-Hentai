//
//  DownloadedGroupViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "ColorThemeViewController.h"

#import "OpenMenuProtocol.h"
#import "DownloadedViewController.h"
#import "DownloadedGroupFilterViewController.h"

@interface DownloadedGroupViewController : ColorThemeViewController <UITableViewDataSource, UITableViewDelegate, DownloadedGroupFilterViewControllerDelegate>

@property (nonatomic, weak) id <MainViewControllerDelegate, OpenMenuProtocol> delegate;

@end
