//
//  FakeViewController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "FakeViewController.h"

@interface FakeViewController ()

@end

@implementation FakeViewController

- (void)whenPresentCompletion {
	[self dismissViewControllerAnimated:NO completion: ^{
	    self.BackBlock();
	}];
}

@end
