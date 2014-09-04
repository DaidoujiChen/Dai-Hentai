//
//  GalleryCell.m
//  e-Hentai
//
//  Created by Jack on 2014/9/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "GalleryCell.h"
#import "UIImageView+WebCache.h"

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
    
    //之後換圖
    [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:@"https://avatars1.githubusercontent.com/u/532720?v=2&s=460"]
                          placeholderImage:nil
                                   options:SDWebImageRefreshCached];
    
}

@end
