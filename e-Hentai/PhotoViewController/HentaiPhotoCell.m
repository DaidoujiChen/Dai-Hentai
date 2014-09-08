//
//  HentaiPhotoCell.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiPhotoCell.h"

@implementation HentaiPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
		self = arrayOfViews[0];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.hentaiImageView.frame = self.bounds;
}

@end
