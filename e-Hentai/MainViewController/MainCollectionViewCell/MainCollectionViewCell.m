//
//  MainCollectionViewCell.m
//  e-Hentai
//
//  Created by Jack on 2014/9/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainCollectionViewCell.h"

@implementation MainCollectionViewCell

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
		self = arrayOfViews[0];
	}
	return self;
}

@end
