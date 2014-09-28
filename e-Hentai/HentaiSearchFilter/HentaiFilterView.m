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
{

    NSMutableArray* filterEnableArray;
}


@end

@implementation HentaiFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        [self setButtons];
    }
    return self;
}

- (void)selectAll
{
    for(int i = 0; i < filterEnableArray.count;i++)
    {
        [filterEnableArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
    }
    
    for(UIButton* btn in self.subviews)
    {
        [self setButtonEnableStyle:btn enable:YES];
    }
}

- (NSArray*)getFilterResult
{
    NSMutableArray* resultArray = [NSMutableArray array];
    
    for(int i = 0; i < filterEnableArray.count; i++){
        
        NSNumber* filterNum = [filterEnableArray objectAtIndex:i];
        if([filterNum boolValue]){
            [resultArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return resultArray;
}

#pragma mark - private


- (void)setButtons
{
    
    filterEnableArray = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < 10; i++)
    {
        CGFloat x = (i % 2 == 0) ? 0 : CGRectGetWidth(self.frame) / 2;
        CGFloat y = (i / 2) * 40;
        
        //init all Tag YES
        NSNumber* tapTag = [NSNumber numberWithBool:YES];
        [filterEnableArray insertObject:tapTag atIndex:i];
        
        UIButton* filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, CGRectGetWidth(self.frame) / 2, 40)];
        filterBtn.tag = i;
        filterBtn.titleLabel.textColor = [UIColor whiteColor];
        NSNumber* filterTag = [NSNumber numberWithInteger:i];
        filterBtn.backgroundColor = [self colorMapping:filterTag];
        [filterBtn setTitle:[self titleMapping:filterTag] forState:UIControlStateNormal];
        [filterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [filterBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:filterBtn];
    }
    
    
}


- (UIColor *)colorMapping:(NSNumber *)filterTag {
	NSDictionary *mapping = @{ [NSNumber numberWithInteger:HentaiFilterTypeDoujinshi] : colorDoujinshi,
		                       [NSNumber numberWithInteger:HentaiFilterTypeManga]     : colorManga,
		                       [NSNumber numberWithInteger:HentaiFilterTypeArtistcg]  : colorArtistcg,
		                       [NSNumber numberWithInteger:HentaiFilterTypeGamecg]    : colorGamecg,
		                       [NSNumber numberWithInteger:HentaiFilterTypeWestern]   : colorWestern,
		                       [NSNumber numberWithInteger:HentaiFilterTypeNonh]      : colorNonh,
		                       [NSNumber numberWithInteger:HentaiFilterTypeImagesets] : colorImageset,
		                       [NSNumber numberWithInteger:HentaiFilterTypeCosplay]   : colorCosplay,
		                       [NSNumber numberWithInteger:HentaiFilterTypeAsianporn] : colorAsianporn,
                               [NSNumber numberWithInteger:HentaiFilterTypeMisc]      : colorMisc};
	return mapping[filterTag] ? mapping[filterTag] : colorAll;
}

- (NSString*)titleMapping:(NSNumber *)filterTag {
	NSDictionary *mapping = @{ [NSNumber numberWithInteger:HentaiFilterTypeDoujinshi] : @"Doujinshi",
		                       [NSNumber numberWithInteger:HentaiFilterTypeManga]     : @"Manga",
		                       [NSNumber numberWithInteger:HentaiFilterTypeArtistcg]  : @"Artistcg",
		                       [NSNumber numberWithInteger:HentaiFilterTypeGamecg]    : @"Gamecg",
		                       [NSNumber numberWithInteger:HentaiFilterTypeWestern]   : @"Western",
		                       [NSNumber numberWithInteger:HentaiFilterTypeNonh]      : @"Nonh",
		                       [NSNumber numberWithInteger:HentaiFilterTypeImagesets] : @"Imageset",
		                       [NSNumber numberWithInteger:HentaiFilterTypeCosplay]   : @"Cosplay",
		                       [NSNumber numberWithInteger:HentaiFilterTypeAsianporn] : @"Asianporn",
                               [NSNumber numberWithInteger:HentaiFilterTypeMisc]      : @"Misc"};
	return mapping[filterTag] ? mapping[filterTag] : @"All";
}

- (void)setButtonEnableStyle:(UIButton*)btn enable:(BOOL)enable
{
    
    NSNumber* filterTag = [NSNumber numberWithInteger:btn.tag];
    if(enable){
        btn.backgroundColor = [self colorMapping:filterTag];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        btn.backgroundColor = [UIColor blackColor];
        [btn setTitleColor:[self colorMapping:filterTag] forState:UIControlStateNormal];
    }
}

- (void) buttonPress:(UIButton*)btn
{
    BOOL enable = [[filterEnableArray objectAtIndex:btn.tag] boolValue];
    enable = !enable;
    [filterEnableArray replaceObjectAtIndex:btn.tag withObject:[NSNumber numberWithBool:enable]];
    [self setButtonEnableStyle:btn enable:enable];
    
}

@end
