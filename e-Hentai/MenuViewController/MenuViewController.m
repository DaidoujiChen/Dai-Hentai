//
//  MenuViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MenuViewController.h"

#import "AppDelegate+SupportKit.h"

#define dataSource LWPArrayR(@"Menu")

@interface MenuViewController ()

@property (nonatomic, strong) NSNumber *unreadCount;

@end

@implementation MenuViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuDefaultCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:dataSource[indexPath.row][@"image"]];
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIColor *textColor = [UIColor flatWhiteColor];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : textColor, NSFontAttributeName : font, NSTextEffectAttributeName : NSTextEffectLetterpressStyle };
    NSString *text;
    if (dataSource[indexPath.row][@"controller"]) {
        text = dataSource[indexPath.row][@"displayName"];
    }
    else {
        text = [NSString stringWithFormat:@"%@ (%@)", dataSource[indexPath.row][@"displayName"], self.unreadCount ? :@"讀取中"];
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    cell.textLabel.attributedText = attributedString;
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
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    @weakify(self);
    appDelegate.monitor = ^(NSNumber *unreadCount) {
        @strongify(self);
        self.unreadCount = unreadCount;
        [self.menuTableView reloadData];
    };
}

@end
