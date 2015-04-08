//
//  DownloadTests.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/2.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import <KIF/CGGeometry-KIFAdditions.h>

@interface DownloadTests : KIFTestCase

@end

@implementation DownloadTests

- (void)beforeEach {
	[tester waitForTimeInterval:2.0f];
}

- (void)afterEach {
	[tester waitForTimeInterval:2.0f];
}

- (void)testDownloadUntilDone {
	
    BOOL isSuccessDownload;
    do {
        [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(arc4random() % 5 + arc4random() % 5)] inTableViewWithAccessibilityIdentifier:@"listTableView"];
        [tester waitForAnimationsToFinish];
        
        //如果是可以下載的話
        if ([tester tryFindingViewWithAccessibilityLabel:@"下載" error:nil]) {
            [tester tapViewWithAccessibilityLabel:@"下載"];
            [tester waitForAnimationsToFinish];
            [tester tapViewWithAccessibilityLabel:@"Done"];
            [tester waitForAnimationsToFinish];
            [self customLongSwipe];
            [tester waitForAnimationsToFinish];
            
            //等下載的 tableview 數量變成 0 的時候表示抓完
            UITableView *downloadManagerTableView = nil;
            UIAccessibilityElement *element = nil;
            do {
                [tester waitForTimeInterval:2.0f];
                [tester waitForAccessibilityElement:&element view:&downloadManagerTableView withIdentifier:@"downloadManagerTableView" tappable:NO];
            }
            while ([downloadManagerTableView.dataSource tableView:downloadManagerTableView numberOfRowsInSection:0]);
            [tester tapViewWithAccessibilityLabel:@"Done"];
            isSuccessDownload = YES;
        }
        //如果下載的 alert 沒有跳出來的話, 表示這本抓過了, 所以點擊 back 重新試抓下一本
        else {
            [tester tapViewWithAccessibilityLabel:@"Back"];
            [tester waitForAnimationsToFinish];
            isSuccessDownload = NO;
        }
    } while (!isSuccessDownload);
}

//滑到底的手勢動作
- (void)customLongSwipe {
	UIView *viewToSwipe = nil;
	UIAccessibilityElement *element = nil;
	[tester waitForAccessibilityElement:&element view:&viewToSwipe withLabel:@"sliderView" value:nil traits:UIAccessibilityTraitNone tappable:NO];
	CGRect elementFrame = [viewToSwipe.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:viewToSwipe];
	CGPoint swipeStart = CGPointCenteredInRect(elementFrame);
	swipeStart.x = [UIScreen mainScreen].bounds.size.width - 10;
	CGPoint swipeEnd = swipeStart;
	swipeEnd.x = 10;
	[viewToSwipe dragFromPoint:swipeStart toPoint:swipeEnd];
}

@end
