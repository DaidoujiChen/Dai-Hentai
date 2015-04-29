//
//  DaiSurvivor.h
//  DaiSurvivor
//
//  Created by DaidoujiChen on 2015/4/29.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DaiSurvivor : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) BOOL (^isNeedAliveInBackground)(void);
@property (nonatomic, copy) void (^totalAliveTime)(NSTimeInterval aliveTime);

+ (DaiSurvivor *)shared;

@end
