//
//  TabBarController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/9.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "TabBarController.h"
#import "GalleryViewController.h"
#import "SettingViewController.h"

@interface TabBarController () <UITabBarControllerDelegate>

@end

@implementation TabBarController

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    for (UIViewController *controller in tabBarController.viewControllers) {
        if (![controller isKindOfClass:[UINavigationController class]]) {
            continue;
        }
        
        UINavigationController *navigation = (UINavigationController *)controller;
        if ([navigation.topViewController isKindOfClass:[GalleryViewController class]]) {
            GalleryViewController *gallery = (GalleryViewController *)navigation.topViewController;
            [gallery.navigationController popViewControllerAnimated:NO];
        }
        else if ([navigation.topViewController isKindOfClass:[SettingViewController class]]) {
            SettingViewController *setting = (SettingViewController *)navigation.topViewController;
            [DBUserPreference setInfo:setting.info];
        }
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    __block NSMutableArray *titles = [NSMutableArray arrayWithObjects:@"列表", @"歷史", @"下載", @"設定", nil];
    [self.tabBar.subviews enumerateObjectsUsingBlock: ^(UIView *v, NSUInteger tabBarIndex, BOOL *tabBarStop) {
        if ([v isKindOfClass:NSClassFromString(@"UITabBarButton")] && v.subviews.count == 2) {
            [v.subviews enumerateObjectsUsingBlock: ^(UIView *buttonSubView, NSUInteger buttonIndex, BOOL *buttonStop) {
                if ([buttonSubView isKindOfClass:NSClassFromString(@"UITabBarButtonLabel")]) {
                    [buttonSubView performSelector:@selector(setText:) withObject:titles.firstObject];
                    [buttonSubView sizeToFit];
                    [titles removeObjectAtIndex:0];
                    *buttonStop = YES;
                }
            }];
        }
    }];
}

@end
