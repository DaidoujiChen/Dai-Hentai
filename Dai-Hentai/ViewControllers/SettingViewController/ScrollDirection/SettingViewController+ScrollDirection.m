//
//  SettingViewController+ScrollDirection.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/11.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SettingViewController+ScrollDirection.h"

@implementation SettingViewController (ScrollDirection)

#pragma mark - Private Instance Method

- (void)onScrollDirectionPress {
    if (self.info.scrollDirection.integerValue == UICollectionViewScrollDirectionVertical) {
        self.info.scrollDirection = @(UICollectionViewScrollDirectionHorizontal);
    }
    else {
        self.info.scrollDirection = @(UICollectionViewScrollDirectionVertical);
    }
    [self displayCurrentScrollDirectionText];
}

- (void)displayCurrentScrollDirectionText {
    if (self.info.scrollDirection.integerValue == UICollectionViewScrollDirectionVertical) {
        self.scrollDirectionLabel.text = @"上下捲動";
    }
    else {
        self.scrollDirectionLabel.text = @"左右捲動";
    }
}

@end
