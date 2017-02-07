//
//  ListViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ListViewController.h"
#import "ListCell.h"
#import "HentaiParser.h"

@interface ListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSCache *thumbCache;
@property (nonatomic, strong) NSMutableArray *galleries;

@end

@implementation ListViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.galleries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(ListCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *galleryInfo = self.galleries[indexPath.row];
    cell.title.text = [galleryInfo[@"title_jpn"] length] ? galleryInfo[@"title_jpn"] : galleryInfo[@"title"];
    cell.category.text = galleryInfo[@"category"];
    cell.rating.text = galleryInfo[@"rating"];
    
    UIImage *cachedImage = [self.thumbCache objectForKey:galleryInfo[@"thumb"]];
    if (cachedImage) {
        cell.thumbImageView.image = cachedImage;
    }
    else {
        NSInteger keepRow = indexPath.row;
        NSURL *url = [NSURL URLWithString:self.galleries[indexPath.row][@"thumb"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSInteger currentIndex = [collectionView indexPathForCell:cell].row;
                    if (keepRow == currentIndex) {
                        cell.thumbImageView.image = image;
                    }
                });
            }
        }] resume];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width - 20;
    CGFloat height = 150;
    return CGSizeMake(width, height);
}

#pragma mark - Private Instance Method

- (void)initValues {
    self.galleries = [NSMutableArray array];
    self.thumbCache = [NSCache new];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak ListViewController *weakSelf = self;
    [HentaiParser requestListAtFilterUrl:@"https://e-hentai.org/" forExHentai:NO completion: ^(HentaiParserStatus status, NSArray *lists) {
        if (status == HentaiParserStatusSuccess) {
            [weakSelf.galleries addObjectsFromArray:lists];
            [weakSelf.collectionView reloadData];
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(layoutSubviews)];
}

@end
