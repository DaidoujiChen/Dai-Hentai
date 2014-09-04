//
//  MainViewController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HentaiParser.h"
#import "HentaiCell.h"
#import "GalleryCell.h"
#import "HentaiNavigationController.h"
#import "PhotoViewController.h"
#import "FakeViewController.h"

@interface MainViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;

@end
