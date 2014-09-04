//
//  GalleryCell.h
//  e-Hentai
//
//  Created by Jack on 2014/9/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel     *cellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

//設定資料
-(void)setGalleryDict:(NSDictionary*)dataDict;

@end
