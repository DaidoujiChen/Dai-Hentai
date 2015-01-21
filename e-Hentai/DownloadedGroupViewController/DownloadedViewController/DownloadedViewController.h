//
//  DownloadedViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"

@interface DownloadedViewController : MainViewController <MWPhotoBrowserDelegate>

//group 或是 searchinfo, 會改變 DownloadedViewController 要秀的資料, 兩個不會同時存在
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSDictionary *searchInfo;

@end
