//
//  FilesManager.m
//  TycheToolsV2
//
//  Created by 啟倫 陳 on 2014/6/30.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "FilesManager.h"

@implementation FilesManager

#pragma mark - class method

+ (FMStream *)documentFolder {
	FMStream *newStream = [FMStream new];
    newStream.basePath = [self documentFolderPathString];
	return newStream;
}

+ (FMStream *)resourceFolder {
	FMStream *newStream = [FMStream new];
    newStream.basePath = [self resourceFolderPathString];
	return newStream;
}

+ (FMStream *)cacheFolder {
	FMStream *newStream = [FMStream new];
    newStream.basePath = [self cacheFolderPathString];
	return newStream;
}

#pragma mark - private

+ (NSString *)documentFolderPathString {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return paths[0];
}

+ (NSString *)resourceFolderPathString {
	return [[NSBundle mainBundle] bundlePath];
}

+ (NSString *)cacheFolderPathString {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return paths[0];
}

@end
