//
//  DownloadManagerViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColorThemeViewController.h"
#import "DownloadManagerCell.h"

@interface DownloadManagerViewController : ColorThemeViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <OpenMenuProtocol> delegate;
@property (weak, nonatomic) IBOutlet UITableView *downloadManagerTableView;

@end
