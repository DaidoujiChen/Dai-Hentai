//
//  DownloadedGroupViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "ColorThemeViewController.h"

#import "OpenMenuProtocol.h"
#import "MenuDefaultCell.h"
#import "DownloadedViewController.h"

@interface DownloadedGroupViewController : ColorThemeViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <MainViewControllerDelegate, OpenMenuProtocol> delegate;

@end
