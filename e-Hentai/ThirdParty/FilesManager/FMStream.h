//
//  FMStream.h
//  TycheToolsV2
//
//  Created by 啟倫 陳 on 2014/6/30.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStream : NSObject

@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSMutableArray *subPaths;

@end

@interface FMStream (Information)

- (NSArray *)listFiles;
- (NSArray *)listFolders;
- (NSString *)currentPath;

@end

@interface FMStream (Folder)

- (FMStream *)cdpp;
- (FMStream *)cd:(NSString *)folder;
- (FMStream *)fcd:(NSString *)folder;

- (FMStream *)md:(NSString *)folder;
- (FMStream *)rd:(NSString *)folder;

- (void)moveToPath:(NSString *)toPath;

@end

@interface FMStream (IO)

- (BOOL)write:(NSData *)data filename:(NSString *)name;
- (NSData *)read:(NSString *)name;

@end
