//
//  HentaiDownloadOperation.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiDownloadOperation.h"

@implementation HentaiDownloadOperation

- (void)main
{
	NSNumber *imageHeight = HentaiLibraryDictionary[self.hentaiKey][[self.downloadURLString lastPathComponent]];
    
    //從 imageHeight 的有無可以判斷這個檔案是否已經有了
	if (!imageHeight) {
		NSURL *url = [NSURL URLWithString:self.downloadURLString];
		NSData *data = [[NSData alloc] initWithContentsOfURL:url];
		UIImage *image = [self resizeImageWithImage:[[UIImage alloc] initWithData:data]];

		if (![self isCancelled]) {
			dispatch_sync(dispatch_get_main_queue(), ^{
			    if (data.length) {
			        [[[FilesManager documentFolder] fcd:self.hentaiKey] write:UIImageJPEGRepresentation(image, 0.7f) filename:[self.downloadURLString lastPathComponent]];
			        [self.delegate downloadResult:self.downloadURLString heightOfSize:image.size.height isSuccess:YES];
				} else {
			        [self.delegate downloadResult:self.downloadURLString heightOfSize:-1 isSuccess:NO];
				}
			});
		}
	} else {
		if (![self isCancelled]) {
			dispatch_sync(dispatch_get_main_queue(), ^{
			    [self.delegate downloadResult:self.downloadURLString heightOfSize:[imageHeight floatValue] isSuccess:YES];
			});
		}
	}
}


#pragma mark - private

//計算符合螢幕 size 的新大小
- (CGSize)calendarNewSize:(UIImage *)image
{
	CGFloat oldWidth = image.size.width;
	CGFloat scaleFactor = [UIScreen mainScreen].bounds.size.height / oldWidth;
	CGFloat newHeight = image.size.height * scaleFactor;
	CGFloat newWidth = oldWidth * scaleFactor;
	return CGSizeMake(newWidth, newHeight);
}

//根據新的大小把圖片縮小, 原網站上面的圖片都過大
- (UIImage *)resizeImageWithImage:(UIImage *)image
{
	CGSize newSize = [self calendarNewSize:image];
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
