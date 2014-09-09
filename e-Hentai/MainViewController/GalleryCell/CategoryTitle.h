//
//  CategoryTitle.h
//  e-Hentai
//
//  Created by Jack on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryTitle : UIView
{
	NSString *categoryString;
	UILabel *categoryLabel;
}

- (void)setCategoryStr:(NSString *)category;

@end
