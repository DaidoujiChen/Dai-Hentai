//
//  HentaiDownloadOperation.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiDownloadImageOperation.h"

@interface HentaiDownloadImageOperation ()

@property (nonatomic, strong) NSMutableData *recvData;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@end

@implementation HentaiDownloadImageOperation

#pragma mark - Methods to Override

- (BOOL)isConcurrent {
	return YES;
}

- (void)start {
	if ([self isCancelled]) {
		[self hentaiFinish];
		return;
	}
    
	[self hentaiStart];
	NSNumber *imageHeight = HentaiCacheLibraryDictionary[self.hentaiKey][[self.downloadURLString lastTwoPathComponent]];
    
	//從 imageHeight 的有無可以判斷這個檔案是否已經有了
	if (!imageHeight) {
		NSURL *url = [NSURL URLWithString:self.downloadURLString];
        
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f] delegate:self startImmediately:NO];
		[conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		[conn start];
	}
	else {
		if (![self isCancelled]) {
			dispatch_sync(dispatch_get_main_queue(), ^{
			    [self.delegate downloadResult:self.downloadURLString heightOfSize:[imageHeight floatValue] isSuccess:YES];
			    [self hentaiFinish];
			});
		}
	}
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
	return YES;
}

#pragma mark - NSURLConnectionDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.recvData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (![self isCancelled]) {
		[self.recvData appendData:data];
	}
	else {
		[self hentaiFinish];
		[connection cancel];
		connection = nil;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (![self isCancelled]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		    UIImage *image = [self resizeImageWithImage:[[UIImage alloc] initWithData:self.recvData]];
            
		    if (self.isCacheOperation) {
		        [[[[FilesManager cacheFolder] fcd:@"Hentai"] fcd:self.hentaiKey] write:UIImageJPEGRepresentation(image, 0.6f) filename:[self.downloadURLString lastTwoPathComponent]];
			}
		    else {
		        [[[[FilesManager documentFolder] fcd:@"Hentai"] fcd:self.hentaiKey] write:UIImageJPEGRepresentation(image, 0.6f) filename:[self.downloadURLString lastTwoPathComponent]];
			}
            
		    //讓檔案轉存這件事情不擋線程
		    dispatch_async(dispatch_get_main_queue(), ^{
		        [self.delegate downloadResult:self.downloadURLString heightOfSize:image.size.height isSuccess:YES];
		        [self hentaiFinish];
			});
		});
	}
	[connection cancel];
	connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (![self isCancelled]) {
		[self.delegate downloadResult:self.downloadURLString heightOfSize:-1 isSuccess:NO];
	}
	[self hentaiFinish];
	[connection cancel];
	connection = nil;
}

#pragma mark - private

- (void)hentaiStart {
	self.isFinished = NO;
	self.isExecuting = YES;
}

- (void)hentaiFinish {
	self.isFinished = YES;
	self.isExecuting = NO;
}

//計算符合螢幕 size 的新大小
- (CGSize)calendarNewSize:(UIImage *)image {
	CGFloat oldWidth = image.size.width;
	CGFloat scaleFactor = [UIScreen mainScreen].bounds.size.height / oldWidth;
	CGFloat newHeight = image.size.height * scaleFactor;
	CGFloat newWidth = oldWidth * scaleFactor;
	return CGSizeMake(newWidth, newHeight);
}

//根據新的大小把圖片縮小, 原網站上面的圖片都過大
- (UIImage *)resizeImageWithImage:(UIImage *)image {
	CGSize newSize = [self calendarNewSize:image];
	UIGraphicsBeginImageContext(newSize);
	//retina 的圖片實在太大, 吃不消 所以先不 retina 試試
	//UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
