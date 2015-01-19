//
//  DownloadedGroupViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DownloadedGroupViewController.h"

@interface DownloadedGroupViewController ()

@property (nonatomic, strong) UITableView *downloadedGroupTableView;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation DownloadedGroupViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuDefaultCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.groups[indexPath.row][@"title"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadedViewController *downloadedViewController = [DownloadedViewController new];
    if ([self.groups[indexPath.row][@"value"] isKindOfClass:[NSString class]]) {
        downloadedViewController.group = self.groups[indexPath.row][@"value"];
    }
    downloadedViewController.delegate = self.delegate;
    [self.navigationController pushViewController:downloadedViewController animated:YES];
}

#pragma mark - private

#pragma mark * init

- (void)setupInitValues {
    self.groups = [NSMutableArray array];
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self.delegate action:@selector(sliderControl)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)setupDownloadedGroupTableView {
    self.downloadedGroupTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.downloadedGroupTableView.delegate = self;
    self.downloadedGroupTableView.dataSource = self;
    self.downloadedGroupTableView.backgroundColor = [UIColor clearColor];
    [self.downloadedGroupTableView registerClass:[MenuDefaultCell class] forCellReuseIdentifier:@"MenuDefaultCell"];
    [self.view addSubview:self.downloadedGroupTableView];
}

#pragma mark * misc

//重載列表
- (void)reloadGroups {
    [self.groups removeAllObjects];
    [self.groups addObject:@{@"title":@"全部", @"value":@""}];
    [self.groups addObject:@{@"title":@"未分類", @"value":[NSNull null]}];
    [self.groups addObjectsFromArray:[HentaiSaveLibrary groups]];
    [self.downloadedGroupTableView reloadData];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupItemsOnNavigation];
    [self setupDownloadedGroupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadGroups];
}

@end
