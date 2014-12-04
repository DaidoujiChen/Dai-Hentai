//
//  DownloadManagerCell.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/6.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DownloadManagerCell.h"

@implementation DownloadManagerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
        self = arrayOfViews[0];
    }
    return self;
}

@end
