//
//  ListCell.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/9.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *rating;

@end
