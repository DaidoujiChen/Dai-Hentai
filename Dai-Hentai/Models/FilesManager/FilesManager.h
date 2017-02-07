//
//  FilesManager.h
//  TycheToolsV2
//
//  Created by 啟倫 陳 on 2014/6/30.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "FMStream.h"

@interface FilesManager : FMStream

+ (FMStream *)documentFolder;
+ (FMStream *)resourceFolder;
+ (FMStream *)cacheFolder;

@end
