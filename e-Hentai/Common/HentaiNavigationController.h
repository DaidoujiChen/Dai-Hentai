//
//  HentaiNavigationController.h
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

//使用這個 navigation controller 來決定畫面是否可以轉向
@interface HentaiNavigationController : UINavigationController

@property (nonatomic, assign) BOOL autoRotate;
@property (nonatomic, assign) UIInterfaceOrientationMask hentaiMask;

@end
