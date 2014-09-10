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
#import "HentaiDownloadOperation.h"

@interface PhotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HentaiDownloadOperationDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSString *hentaiURLString;
@property (nonatomic, strong) NSString *maxHentaiCount;

@property (weak, nonatomic) IBOutlet UITableView *hentaiTableView;

@end
