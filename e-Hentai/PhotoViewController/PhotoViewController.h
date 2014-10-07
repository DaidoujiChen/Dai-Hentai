//
//  PhotoViewController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HentaiNavigationController.h"
#import "FakeViewController.h"
#import "HentaiPhotoCell.h"
#import "HentaiDownloadImageOperation.h"

@interface PhotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HentaiDownloadImageOperationDelegate, UIAlertViewDelegate, HentaiPhotoCellDelegate>

@property (nonatomic, strong) NSDictionary *hentaiInfo;
@property (weak, nonatomic) IBOutlet UITableView *hentaiTableView;

@end
