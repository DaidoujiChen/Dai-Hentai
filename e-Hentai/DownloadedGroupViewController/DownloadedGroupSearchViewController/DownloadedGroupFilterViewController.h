//
//  DownloadedGroupFilterViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/21.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "QuickDialogController.h"

@protocol DownloadedGroupFilterViewControllerDelegate;

@interface DownloadedGroupFilterViewController : QuickDialogController

@property (nonatomic, weak) id <DownloadedGroupFilterViewControllerDelegate> delegate;

@end

@protocol DownloadedGroupFilterViewControllerDelegate <NSObject>

@required
- (void)onSearchFilterDone:(NSDictionary *)searchInfo;

@end