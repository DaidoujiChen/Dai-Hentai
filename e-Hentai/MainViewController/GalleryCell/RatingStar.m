//
//  RatingStar.m
//  e-Hentai
//
//  Created by Jack on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "RatingStar.h"



@implementation RatingStar


- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		starString = @"";
	}
	return self;
}

- (void)setStar:(NSString *)star {
	starString = star;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
	int aSize = CGRectGetWidth(rect);
	const CGFloat color[4] = { 255.0 / 255.0, 215.0 / 255.0, 0.0, 1.0 }; // Gold
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGColorRef aColor = CGColorCreate(colorspace, color);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, aSize);
	CGFloat xCenter = CGRectGetMidX(rect);
	CGFloat yCenter = CGRectGetMidY(rect);
    
    
	float w = CGRectGetWidth(rect);  //星形寬
	double r = w / 2.0;
	float flip = -1.0;
    
    
	CGContextSetFillColorWithColor(context, aColor);
	CGContextSetStrokeColorWithColor(context, aColor);
    
	double theta = 2.0 * M_PI * (2.0 / 5.0); // 144 degrees
    
	CGContextMoveToPoint(context, xCenter, r * flip + yCenter);
    
	for (NSUInteger k = 1; k < 5; k++) {
		float x = r * sin(k * theta);
		float y = r * cos(k * theta);
		CGContextAddLineToPoint(context, x + xCenter, y * flip + yCenter);
	}
    
	CGContextClosePath(context);
	CGContextFillPath(context);
    
	CGFloat fontSize = CGRectGetWidth(rect) / 2;
    
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.alignment = NSTextAlignmentCenter;
    
	NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
		                          NSForegroundColorAttributeName:[UIColor blackColor],
		                          NSParagraphStyleAttributeName:style };
    
	NSString *star = [starString substringToIndex:1];
	NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:star attributes:attributes];
    
    
	[attrStr drawInRect:CGRectMake(CGRectGetMidX(rect) - fontSize / 2,
	                               CGRectGetMidY(rect) - fontSize / 2,
	                               fontSize,
	                               fontSize)];
    CGColorRelease(aColor);
    CGColorSpaceRelease(colorspace);
}

@end
