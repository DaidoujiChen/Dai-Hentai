//
//  CategoryTitle.m
//  e-Hentai
//
//  Created by Jack on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "CategoryTitle.h"

#define colorDoujinshi    [UIColor colorWithRed:251.0 / 255.0 green:99.0 / 255.0 blue:102.0 / 255.0 alpha:1]
#define colorManga        [UIColor colorWithRed:252.0 / 255.0 green:194.0 / 255.0 blue:82.0 / 255.0 alpha:1]
#define colorArtistcg     [UIColor colorWithRed:238.0 / 255.0 green:230.0 / 255.0 blue:102.0 / 255.0 alpha:1]
#define colorGamecg       [UIColor colorWithRed:192.0 / 255.0 green:129.0 / 255.0 blue:127.0 / 255.0 alpha:1]
#define colorWestern      [UIColor colorWithRed:170.0 / 255.0 green:255.0 / 255.0 blue:87.0 / 255.0 alpha:1]
#define colorNonh         [UIColor colorWithRed:132.0 / 255.0 green:199.0 / 255.0 blue:255.0 / 255.0 alpha:1]
#define colorImageset     [UIColor colorWithRed:108.0 / 255.0 green:96.0 / 255.0 blue:255.0 / 255.0 alpha:1]
#define colorCosplay      [UIColor colorWithRed:144.0 / 255.0 green:97.0 / 255.0 blue:181.0 / 255.0 alpha:1]
#define colorAsianporn    [UIColor colorWithRed:245.0 / 255.0 green:175.0 / 255.0 blue:246.0 / 255.0 alpha:1]
#define colorMisc         [UIColor colorWithRed:219.0 / 255.0 green:219.0 / 255.0 blue:219.0 / 255.0 alpha:1]

//Flat Blue
#define CORLOR_TEXT  [UIColor colorWithRed:52.0 / 255.0 green:152.0 / 255.0 blue:219.0 / 255.0 alpha:1]

@implementation CategoryTitle


- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
		categoryString = @"";
		categoryLabel = [UILabel new];
		[self addSubview:categoryLabel];
	}
	return self;
}

- (void)setCategoryStr:(NSString *)category {
	categoryString = category;
	categoryLabel.textColor = [self colorMapping:category];
	[self layoutSubviews];
}

- (UIColor *)colorMapping:(NSString *)category {
	NSDictionary *mapping = @{ @"Doujinshi"       : colorDoujinshi,
		                       @"Manga"           : colorManga,
		                       @"Artist CG Sets"  : colorArtistcg,
		                       @"Game CG Sets"    : colorGamecg,
		                       @"Western"         : colorWestern,
		                       @"Non-H"           : colorNonh,
		                       @"Image Sets"      : colorImageset,
		                       @"Cosplay"         : colorCosplay,
		                       @"Asian Porn"      : colorAsianporn };
	return mapping[category] ? : colorMisc;
}

- (void)layoutSubviews {
	CGRect labelFrame = CGRectOffset(self.bounds, 5, 0); //padding 5
	categoryLabel.frame = labelFrame;
	categoryLabel.backgroundColor = [UIColor clearColor];
	categoryLabel.font = [UIFont systemFontOfSize:14.0];
	categoryLabel.text = categoryString;
    
	self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 4;
}

@end
