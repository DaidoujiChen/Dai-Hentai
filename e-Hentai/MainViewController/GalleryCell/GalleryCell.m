//
//  GalleryCell.m
//  e-Hentai
//
//  Created by Jack on 2014/9/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "GalleryCell.h"
#import "UIImageView+WebCache.h"
#import "CategoryTitle.h"
#import "RatingStar.h"


@implementation GalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        

    }
    return self;
}


#pragma mark -

//設定資料
-(void)setGalleryDict:(NSDictionary*)dataDict
{
    
    self.cellLabel.text = dataDict[@"title"];
    
//    NSString* imgUrl = @"https://avatars1.githubusercontent.com/u/532720?v=2&s=460"; //貓貓圖(公司用)
    NSString* imgUrl = dataDict[@"thumb"]; //(真的H縮圖)
    
    [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                          placeholderImage:nil
                                   options:SDWebImageRefreshCached];
    
    [self.cellCategory setCategoryStr:dataDict[@"category"]];
    [self.cellStar setStar:dataDict[@"rating"]];
    
}

- (void)layoutSubviews
{
    self.cellImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.layer setCornerRadius:CGRectGetHeight(self.cellCategory.frame) / 4];
}

@end
