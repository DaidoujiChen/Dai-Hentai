//
//  SettingViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/31.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "PrivateSettingViewController.h"
#import "SettingViewController+ListAndAPIStatus.h"
#import "SettingViewController+SizeCalculator.h"
#import "SettingViewController+ScrollDirection.h"
#import "SettingViewController+Lock.h"

@implementation SettingViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"ScrollDirectionCell"]) {
        [self onScrollDirectionPress];
    }
    else if ([cell.reuseIdentifier isEqualToString:@"LockThisAppCell"]) {
        [self onLockThisAppPress];
    }
    else if ([cell.reuseIdentifier isEqualToString:@"EhListCheckCell"] || [cell.reuseIdentifier isEqualToString:@"ExListCheckCell"]) {
        [self presentViewController:[self checkViewControllerBy:cell.reuseIdentifier] animated:YES completion:nil];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Instance Method

- (void)initValues {
    self.tableView.delegate = self;
    self.sizeLock = [NSLock new];
    self.statusCheckLock = [NSLock new];
    
    // info 會在切換頁面的時候才被記錄
    self.info = [DBUserPreference info];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayListAndAPIStatus];
    [self sizeCalculator];
    [self displayCurrentScrollDirectionText];
    [self displayLockThisAppText];
}

@end
