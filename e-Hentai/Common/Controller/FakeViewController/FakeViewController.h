//
//  FakeViewController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

//這個 controller 主要的目的在於幫助橫向 controller pop 回直向時的翻轉, 避免 layout 出錯的問題
@interface FakeViewController : UIViewController

@property (nonatomic, copy) void (^BackBlock)(void);

- (void)onPresentCompletion;

@end
