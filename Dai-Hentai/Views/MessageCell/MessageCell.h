//
//  MessageCell.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/31.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
