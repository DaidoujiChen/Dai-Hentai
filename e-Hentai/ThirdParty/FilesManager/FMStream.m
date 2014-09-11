//
//  FMStream.m
//  TycheToolsV2
//
//  Created by 啟倫 陳 on 2014/6/30.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "FMStream.h"

@implementation FMStream

- (id)init {
	self = [super init];
	if (self) {
		self.subPaths = [NSMutableArray array];
	}
	return self;
}

- (NSString *)tmpPath:(NSString *)folder {
	NSMutableArray *tmpSubPaths = [NSMutableArray arrayWithArray:self.subPaths];
	[tmpSubPaths addObject:folder];
	return [self.basePath stringByAppendingPathComponent:[tmpSubPaths componentsJoinedByString:@"/"]];
}

@end

@implementation FMStream (Information)

- (NSArray *)listFiles {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *itemsArray = [fileManager contentsOfDirectoryAtPath:[self currentPath] error:nil];
	NSMutableArray *filesArray = [NSMutableArray array];
	BOOL isFolder;

	for (NSString *item in itemsArray) {
		NSString *itempath = [[self currentPath] stringByAppendingPathComponent:item];
		[fileManager fileExistsAtPath:itempath isDirectory:(&isFolder)];

		if (!isFolder) {
			[filesArray addObject:item];
		}
	}
	return filesArray;
}

- (NSArray *)listFolders {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *itemsArray = [fileManager contentsOfDirectoryAtPath:[self currentPath] error:nil];
	NSMutableArray *foldersArray = [NSMutableArray array];
	BOOL isFolder;

	for (NSString *item in itemsArray) {
		NSString *itempath = [[self currentPath] stringByAppendingPathComponent:item];
		[fileManager fileExistsAtPath:itempath isDirectory:(&isFolder)];

		if (isFolder) {
			[foldersArray addObject:item];
		}
	}
	return foldersArray;
}

- (NSString *)currentPath {
	return [self.basePath stringByAppendingPathComponent:[self.subPaths componentsJoinedByString:@"/"]];
}

@end


@implementation FMStream (Folder)

- (FMStream *)cdpp {
	[self.subPaths removeLastObject];
	return self;
}

- (FMStream *)cd:(NSString *)folder {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:[self tmpPath:folder]]) {
		[self.subPaths addObject:folder];
		return self;
	}
	else {
		return nil;
	}
}

- (FMStream *)fcd:(NSString *)folder {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:[self tmpPath:folder]]) {
		[self.subPaths addObject:folder];
	}
	else {
		[[self md:folder] cd:folder];
	}
	return self;
}

- (FMStream *)md:(NSString *)folder {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:[self tmpPath:folder]]) {
		if ([[NSFileManager defaultManager] createDirectoryAtPath:[self tmpPath:folder] withIntermediateDirectories:NO attributes:nil error:nil]) {
			return self;
		}
	}
	return nil;
}

- (FMStream *)rd:(NSString *)folder {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:[self tmpPath:folder]]) {
		if ([fileManager removeItemAtPath:[self tmpPath:folder] error:nil]) {
			return self;
		}
	}
	return nil;
}

- (void)moveToPath:(NSString *)toPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager moveItemAtPath:self.currentPath toPath:toPath error:nil];
}

@end


@implementation FMStream (IO)

- (BOOL)write:(NSData *)data filename:(NSString *)name {
	return [data writeToFile:[[self currentPath] stringByAppendingPathComponent:name] atomically:YES];
}

- (NSData *)read:(NSString *)name {
	return [[NSFileManager defaultManager] contentsAtPath:[[self currentPath] stringByAppendingPathComponent:name]];
}

@end
