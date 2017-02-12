//
//  GalleryCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/14.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "GalleryCell.h"

@implementation GalleryCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.galleryImageView.image = nil;
    self.galleryImageView.backgroundColor = [UIColor blackColor];
}

@end
