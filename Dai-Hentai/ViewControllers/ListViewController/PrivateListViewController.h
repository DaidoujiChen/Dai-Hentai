//
//  PrivateListViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/24.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ListViewController.h"
#import "Couchbase.h"
#import "UIAlertController+Block.h"
#import "MessageCell.h"

@interface ListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) Class parser;
@property (nonatomic, strong) NSMutableArray<HentaiInfo *> *galleries;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSLock *pageLocker;
@property (nonatomic, assign) BOOL isEndOfGalleries;
@property (nonatomic, assign) BOOL isLoading;

- (void)initValues;
- (void)showMessageTo:(MessageCell *)cell onLoading:(BOOL)isLoading;
- (void)reloadGalleries;
- (void)onCellBeSelectedAction:(HentaiInfo *)info;

@end
