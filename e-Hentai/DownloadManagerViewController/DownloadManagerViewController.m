//
//  DownloadManagerViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadManagerViewController.h"

@interface DownloadManagerViewController ()

@property (nonatomic, strong) NSDictionary *centerDetail;
@property (nonatomic, strong) UITableView *downloadManagerTableView;

@end

@implementation DownloadManagerViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        return [self.centerDetail[@"waitingItems"] count];
    }
    else {
        return [self.centerDetail[@"downloadingItems"] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DownloadManagerCell";
    DownloadManagerCell *cell = (DownloadManagerCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *currentArray;
    if (indexPath.section) {
        currentArray = self.centerDetail[@"waitingItems"];
        cell.statusLabel.text = @"等待下載中...";
    }
    else {
        currentArray = self.centerDetail[@"downloadingItems"];
        NSString *recvCountString = currentArray[indexPath.row][@"recvCount"];
        NSString *totalCountString = currentArray[indexPath.row][@"totalCount"];
        cell.statusLabel.text = [NSString stringWithFormat:@"下載中 : %@ / %@", recvCountString, totalCountString];
    }
    NSDictionary *currentHentaiInfo = currentArray[indexPath.row][@"hentaiInfo"];
    [cell.thumbnailImageView sd_setImageWithURL:currentHentaiInfo[@"thumb"] placeholderImage:nil options:SDWebImageRefreshCached | SDWebImageHandleCookies];
    cell.titleLabel.text = currentHentaiInfo[@"title"];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section) {
        return @"等待下載";
    }
    else {
        return @"正在下載";
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 137.0f;
}

#pragma mark - private

- (void)setupItemsOnNavigation {    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.delegate action:@selector(sliderControl)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)setupDownloadManagerTableView {
    self.downloadManagerTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.downloadManagerTableView.accessibilityIdentifier = @"downloadManagerTableView";
    self.downloadManagerTableView.delegate = self;
    self.downloadManagerTableView.dataSource = self;
    self.downloadManagerTableView.backgroundColor = [UIColor clearColor];
    [self.downloadManagerTableView registerClass:[DownloadManagerCell class] forCellReuseIdentifier:@"DownloadManagerCell"];
    [self.view addSubview:self.downloadManagerTableView];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下載管理員";
    [self setupItemsOnNavigation];
    [self setupDownloadManagerTableView];
    @weakify(self);
    [HentaiDownloadCenter centerMonitor: ^(NSDictionary *centerDetail) {
        @strongify(self);
        self.centerDetail = centerDetail;
        [self.downloadManagerTableView reloadData];
    }];
}

@end
