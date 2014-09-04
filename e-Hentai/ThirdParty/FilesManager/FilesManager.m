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

+ (FMStream *)documentFolder
{
	FMStream *newStream = [FMStream new];
	[newStream setBasePath:[self documentFolderPathString]];
	return newStream;
}

+ (FMStream *)resourceFolder
{
	FMStream *newStream = [FMStream new];
	[newStream setBasePath:[self resourceFolderPathString]];
	return newStream;
}

#pragma mark - private

+ (NSString *)documentFolderPathString
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return paths[0];
}

+ (NSString *)resourceFolderPathString
{
	return [[NSBundle mainBundle] bundlePath];
}

@end
