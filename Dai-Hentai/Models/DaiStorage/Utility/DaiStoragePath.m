//
//  DaiStoragePath.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/9.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStoragePath.h"

@interface DaiStoragePath ()

@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSMutableArray *subPaths;

@end

@implementation DaiStoragePath

@dynamic path;

#pragma mark - dynamic

- (NSString *)path {
    return [self.basePath stringByAppendingPathComponent:[self.subPaths componentsJoinedByString:@"/"]];
}

#pragma mark - class method

+ (DaiStoragePath *)document {
	DaiStoragePath *newStream = [DaiStoragePath new];
	newStream.basePath = [self documentPath];
	return newStream;
}

+ (DaiStoragePath *)resource {
	DaiStoragePath *newStream = [DaiStoragePath new];
	newStream.basePath = [self resourcePath];
	return newStream;
}

#pragma mark - private class method

+ (NSString *)documentPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return paths[0];
}

+ (NSString *)resourcePath {
	return [[NSBundle mainBundle] bundlePath];
}

#pragma mark - instance method

- (DaiStoragePath *)fcd:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:[self tmpPath:directory]]) {
		[self.subPaths addObject:directory];
	}
	else {
		[[self md:directory] cd:directory];
	}
	return self;
}

#pragma mark - private instance method

- (NSString *)tmpPath:(NSString *)directory {
	NSMutableArray *tmpSubPaths = [NSMutableArray arrayWithArray:self.subPaths];
	[tmpSubPaths addObject:directory];
	return [self.basePath stringByAppendingPathComponent:[tmpSubPaths componentsJoinedByString:@"/"]];
}

- (DaiStoragePath *)cd:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:[self tmpPath:directory]]) {
		[self.subPaths addObject:directory];
		return self;
	}
	else {
		return nil;
	}
}

- (DaiStoragePath *)md:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:[self tmpPath:directory]]) {
		if ([[NSFileManager defaultManager] createDirectoryAtPath:[self tmpPath:directory] withIntermediateDirectories:NO attributes:nil error:nil]) {
			return self;
		}
	}
	return nil;
}

#pragma mark - life cycle

- (id)init {
    self = [super init];
    if (self) {
        self.subPaths = [NSMutableArray array];
    }
    return self;
}

@end
