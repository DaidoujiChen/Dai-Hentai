//
//  VideoViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "VideoViewController.h"

#import "MeetAVParser.h"

@interface VideoViewController ()

@property (nonatomic, strong) NSArray *listArray;

@end

@implementation VideoViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.listArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
    NSURL *imageURL = [NSURL URLWithString:self.listArray[indexPath.row][@"thumb"]];
    [cell.thumbImageView sd_setImageWithURL:imageURL];
    cell.titleLabel.text = self.listArray[indexPath.row][@"title"];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD show];
    @weakify(self);
    [MeetAVParser parseVideoFrom:self.listArray[indexPath.row][@"url"] completion:^(MeetParserStatus status, NSString *videoURL) {
        @strongify(self);
        if (status == MeetParserStatusSuccess) {
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
            [self.delegate needToPresentMovieViewController:player];
            [SVProgressHUD dismiss];
        }
        else {
            [UIAlertView hentai_alertViewWithTitle:@"錯誤 >X<" message:@"影片格式錯誤或是網路錯誤~ >x<" cancelButtonTitle:@"不好意思~ >X<"];
        }
    }];
}

#pragma mark - private

- (void)setupItemsOnNavigation {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self.delegate action:@selector(sliderControl)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

#pragma mark - life cycle

- (id)init {
    self = [super initWithNibName:xibName bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupItemsOnNavigation];
    self.title = @"MeetAV";
    [self.meetAVCollectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"VideoCollectionViewCell"];
    
    [SVProgressHUD show];
    [MeetAVParser requestListForQuery:@"鬼父" completion:^(MeetParserStatus status, NSArray *listArray) {
        if (status == MeetParserStatusSuccess) {
            self.listArray = listArray;
            [self.meetAVCollectionView reloadData];
        }
        else {
            [UIAlertView hentai_alertViewWithTitle:@"錯誤 >X<" message:@"先選到別的功能吧~" cancelButtonTitle:@"謝謝~ >X<"];
        }
        [SVProgressHUD dismiss];
    }];
}

@end
