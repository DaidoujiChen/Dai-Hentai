//
//  DaiInboxView.h
//  DaiInboxHUD
//
//  Created by 啟倫 陳 on 2014/10/31.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DaiInboxDisplayLink.h"

@interface DaiInboxView : UIView <DaiInboxDisplayLinkDelegate>

@property (nonatomic, strong) NSArray *hudColors;
@property (nonatomic, assign) CGFloat hudLineWidth;

@end
