//
//  GroupManager.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "GroupManager.h"
#import "GroupSelectViewController.h"

@implementation GroupManager

+ (void)presentFromViewController:(UIViewController *)viewController completion:(void (^)(NSString *selectedGroup))completion {
    [self presentFromViewController:viewController originGroup:@"" completion:completion];
}

+ (void)presentFromViewController:(UIViewController *)viewController originGroup:(NSString *)originGroup completion:(void (^)(NSString *selectedGroup))completion {
    GroupSelectViewController *groupSelectViewController = [GroupSelectViewController new];
    groupSelectViewController.completion = completion;
    groupSelectViewController.originGroup = originGroup;
    HentaiNavigationController *hentaiNavigation = [[HentaiNavigationController alloc] initWithRootViewController:groupSelectViewController];
    hentaiNavigation.autoRotate = NO;
    hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
    [viewController presentViewController:hentaiNavigation animated:YES completion: ^{
    }];
}

@end
