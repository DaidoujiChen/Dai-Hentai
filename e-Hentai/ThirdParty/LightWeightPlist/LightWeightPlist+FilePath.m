//
//  LightWeightPlist+FilePath.m
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/3/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "LightWeightPlist+FilePath.h"

#import "LightWeightPlist+AccessObject.h"

@implementation LightWeightPlist (FilePath)

#pragma mark - class method

+ (NSString *)resourceFolderPathWithFilename:(NSString *)filename
{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", filename]];
}

+ (NSString *)documentFolderPathWithFilename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", filename]];
}

@end
