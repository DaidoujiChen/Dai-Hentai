//
//  DaiSurvivor.m
//  DaiSurvivor
//
//  Created by DaidoujiChen on 2015/4/29.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiSurvivor.h"

#define MaxBackgroundTimeRemaining 180.0f

@interface DaiSurvivor ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSDate *beginTime;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isUpdatingLocation;
@property (nonatomic, assign) BOOL isEnterBackground;
@property (nonatomic, readonly) NSTimeInterval backgroundTimeRemaining;

@end

@implementation DaiSurvivor

#pragma mark - readonly property

- (NSTimeInterval)backgroundTimeRemaining {
	return [UIApplication sharedApplication].backgroundTimeRemaining;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	[self.locationManager stopUpdatingLocation];
	self.isUpdatingLocation = NO;
	[self refreshBackgroundTaskIdentifier];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self.locationManager stopUpdatingLocation];
	self.isUpdatingLocation = NO;
	[self refreshBackgroundTaskIdentifier];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}
}

#pragma mark - life cycle

+ (void)load {
	DaiSurvivor *shared = [self shared];
	[[NSNotificationCenter defaultCenter] addObserver:shared selector:@selector(handleEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:shared selector:@selector(handleEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - private instance method

#pragma mark * handle app enter background / foreground

- (void)handleEnterBackground {
	//從外部判斷是否要在背景運行
	BOOL isNeedAliveInBackground = NO;
	if (self.isNeedAliveInBackground) {
		isNeedAliveInBackground = self.isNeedAliveInBackground();
	}

	//如果還沒有進背景而且外部允許背景運行
	if (!self.isEnterBackground && isNeedAliveInBackground) {
		self.beginTime = [NSDate date];
		self.isEnterBackground = YES;
		[self refreshBackgroundTaskIdentifier];

		//不阻礙 main thread, 每 5 秒檢查一次, 如果剩餘時間小於 30 秒且沒有正在抓取 gps 時, 切入 main thread 要一次 location
		//藉此重刷系統的 backgroundTimeRemaining, 不過怪異的是, 有些時候是刷不成功的 O口O"
		//但是在 30 秒以下的時候, 大概每 5 秒刷一次, 可以提高成功的機會
		__weak typeof(self) weakSelf = self;

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			while (1) {
			    [NSThread sleepForTimeInterval:5.0f];
			    if (!weakSelf.isEnterBackground) {
			        break;
				}
                
			    if (weakSelf.backgroundTimeRemaining < 30.0f && !weakSelf.isUpdatingLocation && weakSelf.isNeedAliveInBackground()) {
			        dispatch_async(dispatch_get_main_queue(), ^{
						[weakSelf requestUpdatingLocation];
					});
				}
			}
		});
	}
}

//回到前景的時候, 回報總共時間, 結束背景的 task
- (void)handleEnterForeground {
	if (self.isEnterBackground) {
		self.isEnterBackground = NO;
		if (self.totalAliveTime) {
			self.totalAliveTime([[NSDate date] timeIntervalSince1970] - [self.beginTime timeIntervalSince1970]);
		}
		[self endCurrentBackgroundTask];
	}
}

#pragma mark * BackgroundTaskIdentifier control

//整套刷新 BackgroundTaskIdentifier 的動作
- (void)refreshBackgroundTaskIdentifier {
	UIBackgroundTaskIdentifier newTask = [self newBackgroundTaskIdentifier];
	[self endCurrentBackgroundTask];
	self.bgTask = newTask;
}

//結束當前的 BackgroundTaskIdentifier
- (void)endCurrentBackgroundTask {
	if (self.bgTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
		self.bgTask = UIBackgroundTaskInvalid;
	}
}

//建立一個新的 BackgroundTaskIdentifier
- (UIBackgroundTaskIdentifier)newBackgroundTaskIdentifier {
	UIBackgroundTaskIdentifier newBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
	}];
	return newBgTask;
}

#pragma mark * requst location updating

//取得 gps 座標, 藉此刷新 backgroundTimeRemaining
- (void)requestUpdatingLocation {
	self.isUpdatingLocation = YES;
	[self.locationManager startUpdatingLocation];
}

#pragma mark * Location access methods (iOS8/Xcode6)

//檢查是否有 Always 的權限
- (void)checkingLocationAccess {
	if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
		CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
		if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有權限才有背景下載~O3O" message:@"開啟背景下載的黑魔法~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"設定", nil];
			[alert show];
			return;
		}
		[self.locationManager requestAlwaysAuthorization];
	}
}

#pragma mark - shared instance

+ (DaiSurvivor *)shared {
	static DaiSurvivor *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [DaiSurvivor new];
		shared.bgTask = UIBackgroundTaskInvalid;
		shared.isUpdatingLocation = NO;
		shared.isEnterBackground = NO;
		shared.locationManager = [CLLocationManager new];
		shared.locationManager.delegate = (id <CLLocationManagerDelegate> )shared;
		[shared checkingLocationAccess];
	});
	return shared;
}

@end
