//
//  MainViewController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColorThemeViewController.h"
#import "HentaiParser.h"
#import "GalleryCell.h"
#import "HentaiNavigationController.h"
#import "PhotoViewController.h"
#import "FakeViewController.h"
#import "SearchFilterViewController.h"

@protocol MainViewControllerDelegate;

@interface MainViewController : ColorThemeViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, SearchFilterViewControllerDelegate>

@property (nonatomic, weak) id <MainViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;

@end

@protocol MainViewControllerDelegate <NSObject>

@required
- (void)needToPushViewController:(UIViewController *)controller;

@end
