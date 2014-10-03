//
//  HentaiDownloadCenter.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/11.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiDownloadCenter.h"

#import <objc/runtime.h>

@implementation HentaiDownloadCenter

#pragma mark - class method

+ (void)addBook:(NSDictionary *)bookInfo {
	BOOL isExist = NO;
    
	//如果下載過的話不給下
	for (NSDictionary *eachInfo in HentaiSaveLibraryArray) {
		if ([eachInfo[@"url"] isEqualToString:bookInfo[@"url"]]) {
			isExist = YES;
			break;
		}
	}
    
	//如果在 queue 裡面也不給下
    isExist = isExist | [self isDownloading:bookInfo];
    
	if (isExist) {
        [UIAlertView hentai_alertViewWithTitle:@"不行~ O3O" message:@"你可能已經下載過或是正在下載中!" cancelButtonTitle:@"確定"];
	}
	else {
		HentaiDownloadBookOperation *newOperation = [HentaiDownloadBookOperation new];
		newOperation.bookInfo = bookInfo;
		[[self allBooksOperationQueue] addOperation:newOperation];
	}
}

+ (BOOL)isDownloading:(NSDictionary *)bookInfo {
    BOOL isExist = NO;
    
	for (HentaiDownloadBookOperation *eachOperation in[[self allBooksOperationQueue] operations]) {
		if ([eachOperation.bookInfo[@"url"] isEqualToString:bookInfo[@"url"]]) {
			isExist = YES;
			break;
		}
	}
    return isExist;
}

#pragma mark - private

+ (NSOperationQueue *)allBooksOperationQueue {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    NSOperationQueue *hentaiQueue = [NSOperationQueue new];
	    [hentaiQueue setMaxConcurrentOperationCount:2];
	    objc_setAssociatedObject(self, _cmd, hentaiQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	});
	return objc_getAssociatedObject(self, _cmd);
}

@end
