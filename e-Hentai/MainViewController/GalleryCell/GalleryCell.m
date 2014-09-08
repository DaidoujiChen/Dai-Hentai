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



#pragma mark -

//設定資料
-(void)setGalleryDict:(NSDictionary*)dataDict
{
    
    self.cellLabel.text = dataDict[@"title"];
    
    
    BOOL enableImageMode = [dataDict[imageMode] boolValue];
    
    NSString* imgUrl = @"https://avatars1.githubusercontent.com/u/532720?v=2&s=460"; //貓貓圖(公司用)
    
    if(enableImageMode)
    {
        imgUrl = dataDict[@"thumb"];//(真的H縮圖)
    }
    
    [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                          placeholderImage:nil
                                   options:SDWebImageRefreshCached];
    
    [self.cellCategory setCategoryStr:dataDict[@"category"]];
    [self.cellStar setStar:dataDict[@"rating"]];
    
}

- (void)layoutSubviews
{
    //Fit並置中
    self.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cellImageView setClipsToBounds:YES];
    self.cellImageView.center = CGPointMake(self.cellImageView.center.x, CGRectGetMidY(self.bounds));
    self.layer.cornerRadius = CGRectGetHeight(self.cellCategory.frame) / 4;
}

@end
