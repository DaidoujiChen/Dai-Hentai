//
//  FakeViewController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FakeViewController : UIViewController

@property (nonatomic, copy) void (^BackBlock)(void);

- (void)onPresentCompletion;

@end
