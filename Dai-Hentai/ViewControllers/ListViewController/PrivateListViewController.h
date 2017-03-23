//
//  PrivateListViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/24.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ListViewController.h"
#import "Couchbase.h"

@interface ListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) Class parser;
@property (nonatomic, strong) NSMutableArray<HentaiInfo *> *galleries;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSLock *pageLocker;
@property (nonatomic, assign) BOOL isEndOfGalleries;

- (void)reloadGalleries;

@end
