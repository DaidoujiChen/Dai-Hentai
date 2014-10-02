//
//  MenuViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MenuViewController.h"

#define dataSource LWPArrayR(@"Menu")

@interface MenuViewController ()

@end

@implementation MenuViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuDefaultCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = dataSource[indexPath.row][@"displayName"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate needToChangeViewController:dataSource[indexPath.row][@"controller"]];
}

#pragma mark - life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
    [self.menuTableView registerClass:[MenuDefaultCell class] forCellReuseIdentifier:@"MenuDefaultCell"];
}

@end
