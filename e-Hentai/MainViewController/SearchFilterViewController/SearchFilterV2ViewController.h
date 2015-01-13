//
//  SearchFilterV2ViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/13.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "QuickDialogController.h"

@protocol SearchFilterV2ViewControllerDelegate;

@interface SearchFilterV2ViewController : QuickDialogController

@property (nonatomic, weak) id <SearchFilterV2ViewControllerDelegate> delegate;

@end

@protocol SearchFilterV2ViewControllerDelegate <NSObject>

@required
- (void)onSearchFilterDone;

@end