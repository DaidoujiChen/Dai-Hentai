//
//  MenuViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate+SupportKit.h"

@interface MenuViewController ()

@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) UITableView *menuTableView;

@end

@implementation MenuViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Menu shared].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    MenuItem *item = [Menu shared].items[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:item.image];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIColor *textColor = [UIColor flatWhiteColor];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : textColor, NSFontAttributeName : font, NSTextEffectAttributeName : NSTextEffectLetterpressStyle };
    NSString *text;
    if (item.controller) {
        text = item.displayName;
    }
    else {
        text = [NSString stringWithFormat:@"%@ (%@)", item.displayName, self.unreadCount ? : @"讀取中"];
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    cell.textLabel.attributedText = attributedString;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [Menu shared].items[indexPath.row];
    [self.delegate needToChangeViewController:item.controller];
}

#pragma mark - private instance method

- (void)setupMenuTableView {
    self.menuTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.menuTableView.backgroundColor = [UIColor clearColor];
    self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:self.menuTableView];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTableView];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    @weakify(self);
    appDelegate.monitor = ^(NSNumber *unreadCount) {
        @strongify(self);
        self.unreadCount = unreadCount;
        [self.menuTableView reloadData];
    };
}

@end
