//
//  MainTableViewCell.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/5.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
        self = arrayOfViews[0];
        
        [self.contentView hentai_pathShadow];
        self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundImageView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)prepareForReuse {
    self.thumbImageView.image = nil;
    [self.thumbImageView hentai_pathShadow];
    self.backgroundImageView.image = nil;
    [self.backgroundImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
