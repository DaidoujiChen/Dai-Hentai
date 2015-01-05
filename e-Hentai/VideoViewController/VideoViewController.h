//
//  VideoViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "ColorThemeViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "VideoCollectionViewCell.h"

@protocol VideoViewControllerDelegate;

@interface VideoViewController : ColorThemeViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id <VideoViewControllerDelegate, OpenMenuProtocol> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *meetAVCollectionView;

@end

@protocol VideoViewControllerDelegate <NSObject>

@required
- (void)needToPresentMovieViewController:(MPMoviePlayerViewController *)controller;

@end
