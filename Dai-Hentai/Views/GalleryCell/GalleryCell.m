//
//  GalleryCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/14.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "GalleryCell.h"
#import "UIAlertController+Block.h"

@interface GalleryCell ()

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, readonly) UIViewController *rootViewController;

@end

@implementation GalleryCell

#pragma mark - Private Instance Method

- (UIViewController *)rootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (self.galleryImageView.image && !self.isPresenting) {
        self.isPresenting = YES;
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[ self.galleryImageView.image ] applicationActivities:nil];
        
        __weak GalleryCell *weakSelf = self;
        activityViewController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            weakSelf.isPresenting = NO;
        };
        [self.rootViewController presentViewController:activityViewController animated:YES completion:nil];
    }
}

#pragma mark - Life Cycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.delaysTouchesBegan = YES;
    longPressGestureRecognizer.minimumPressDuration = 1.0f;
    [self addGestureRecognizer:longPressGestureRecognizer];
    self.isPresenting = NO;
    return [super initWithCoder:aDecoder];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.galleryImageView.image = nil;
    self.galleryImageView.backgroundColor = [UIColor blackColor];
}

@end
