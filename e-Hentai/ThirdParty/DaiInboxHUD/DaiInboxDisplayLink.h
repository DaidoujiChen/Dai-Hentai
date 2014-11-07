//
//  DaiInboxDisplayLink.h
//  DaiInboxHUD
//
//  Created by 啟倫 陳 on 2014/11/7.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//idea from http://www.paulwrightapps.com/blog/2014/8/20/creating-smooth-frame-by-frame-animations-on-ios-based-on-the-time-passed-between-frames

@protocol DaiInboxDisplayLinkDelegate;

@interface DaiInboxDisplayLink : NSObject

@property (nonatomic, weak) id <DaiInboxDisplayLinkDelegate> delegate;

- (id)initWithDelegate:(id <DaiInboxDisplayLinkDelegate> )delegate;
- (void)removeDisplayLink;

@end

@protocol DaiInboxDisplayLinkDelegate <NSObject>

@required
- (void)displayWillUpdateWithDeltaTime:(CFTimeInterval)deltaTime;

@end
