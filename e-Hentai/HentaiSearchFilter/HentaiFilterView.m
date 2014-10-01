//
//  HentaiFilterView.m
//  e-Hentai
//
//  Created by OptimusKe on 2014/9/28.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiFilterView.h"
#import "HentaiSearchFilter.h"

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
#define colorAll          [UIColor grayColor]

@interface HentaiFilterView ()

@property (nonatomic, strong) NSMutableArray *filterEnableArray;

@end

@implementation HentaiFilterView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor blackColor];
		self.filterEnableArray = [NSMutableArray array];
		for (int i = 0; i < 10; i++) {
			[self.filterEnableArray addObject:@(YES)];
		}
	}
	return self;
}

#pragma mark - instance method

- (void)selectAll {
	for (int i = 0; i < [self.filterEnableArray count]; i++) {
		[self.filterEnableArray replaceObjectAtIndex:i withObject:@(YES)];
	}
    
	for (UIButton *btn in self.subviews) {
		[self setButtonEnableStyle:btn enable:YES];
	}
}

- (NSArray *)filterResult {
	NSMutableArray *resultArray = [NSMutableArray array];
    
	for (int i = 0; i < [self.filterEnableArray count]; i++) {
		NSNumber *filterNum = self.filterEnableArray[i];
		if ([filterNum boolValue]) {
			[resultArray addObject:@(i)];
		}
	}
	return resultArray;
}

#pragma mark - override method

- (void)layoutSubviews {
	[super layoutSubviews];
	[self setButtons];
}

#pragma mark - private

- (void)setButtons {
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
	for (int i = 0; i < 10; i++) {
		NSNumber *flag = self.filterEnableArray[i];
		CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.frame) / 2, 40);
		CGFloat x = (i % 2 == 0) ? 0 : buttonSize.width;
		CGFloat y = (i / 2) * buttonSize.height;
		UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize.width, buttonSize.height)];
		filterBtn.tag = i;
		filterBtn.titleLabel.textColor = [UIColor whiteColor];
		[self setButtonEnableStyle:filterBtn enable:[flag boolValue]];
		[filterBtn setTitle:[self titleMapping:@(i)] forState:UIControlStateNormal];
		[filterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[filterBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:filterBtn];
	}
}

- (UIColor *)colorMapping:(NSNumber *)filterTag {
	NSDictionary *mapping = @{ @(HentaiFilterTypeDoujinshi) : colorDoujinshi,
		                       @(HentaiFilterTypeManga)     : colorManga,
		                       @(HentaiFilterTypeArtistcg)  : colorArtistcg,
		                       @(HentaiFilterTypeGamecg)    : colorGamecg,
		                       @(HentaiFilterTypeWestern)   : colorWestern,
		                       @(HentaiFilterTypeNonh)      : colorNonh,
		                       @(HentaiFilterTypeImagesets) : colorImageset,
		                       @(HentaiFilterTypeCosplay)   : colorCosplay,
		                       @(HentaiFilterTypeAsianporn) : colorAsianporn,
		                       @(HentaiFilterTypeMisc)      : colorMisc };
	return mapping[filterTag] ? mapping[filterTag] : colorAll;
}

- (NSString *)titleMapping:(NSNumber *)filterTag {
	NSDictionary *mapping = @{ @(HentaiFilterTypeDoujinshi) : @"Doujinshi",
		                       @(HentaiFilterTypeManga)     : @"Manga",
		                       @(HentaiFilterTypeArtistcg)  : @"Artistcg",
		                       @(HentaiFilterTypeGamecg)    : @"Gamecg",
		                       @(HentaiFilterTypeWestern)   : @"Western",
		                       @(HentaiFilterTypeNonh)      : @"Nonh",
		                       @(HentaiFilterTypeImagesets) : @"Imageset",
		                       @(HentaiFilterTypeCosplay)   : @"Cosplay",
		                       @(HentaiFilterTypeAsianporn) : @"Asianporn",
		                       @(HentaiFilterTypeMisc)      : @"Misc" };
	return mapping[filterTag] ? mapping[filterTag] : @"All";
}

- (void)setButtonEnableStyle:(UIButton *)btn enable:(BOOL)enable {
	NSNumber *filterTag = @(btn.tag);
	if (enable) {
		btn.backgroundColor = [self colorMapping:filterTag];
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	else {
		btn.backgroundColor = [UIColor blackColor];
		[btn setTitleColor:[self colorMapping:filterTag] forState:UIControlStateNormal];
	}
}

- (void)buttonPress:(UIButton *)btn {
	BOOL enable = [self.filterEnableArray[btn.tag] boolValue];
	enable = !enable;
	[self.filterEnableArray replaceObjectAtIndex:btn.tag withObject:@(enable)];
	[self setButtonEnableStyle:btn enable:enable];
}

@end
