//
//  GalleryCell.h
//  e-Hentai
//
//  Created by Jack on 2014/9/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define imageMode @"IMAGE_MODE"

@class CategoryTitle;
@class RatingStar;

@interface GalleryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel*       cellLabel;
@property (weak, nonatomic) IBOutlet UIImageView*   cellImageView;
@property (weak, nonatomic) IBOutlet CategoryTitle* cellCategory;
@property (weak, nonatomic) IBOutlet RatingStar*    cellStar;

//設定資料
-(void)setGalleryDict:(NSDictionary*)dataDict;

@end
