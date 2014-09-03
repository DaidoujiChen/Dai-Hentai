//
//  HentaiNavigationController.m
//  TEST_2014_9_2
//
//  Created by 啟倫 陳 on 2014/9/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiNavigationController.h"

@interface HentaiNavigationController ()

@end

@implementation HentaiNavigationController


#pragma mark - Configuring the View Rotation Settings

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.hentaiMask;
}


@end
