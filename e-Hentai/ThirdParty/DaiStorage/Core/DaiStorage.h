//
//  DaiStorage.h
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/8.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaiStorageDefine.h"
#import "DaiStorageArray.h"
#import "DaiStoragePath.h"

@interface DaiStorage : NSObject

@property (nonatomic, readonly) NSDictionary *storeContents;

+ (instancetype)shared;

- (void)importPath:(DaiStoragePath *)importPath;
- (void)importPath:(DaiStoragePath *)importPath defaultPath:(DaiStoragePath *)defaultPath;
- (BOOL)exportPath:(DaiStoragePath *)exportPath;

- (void)reworkRuleForClass:(__unsafe_unretained Class)aClass whenImport:(ImportRuleBlock)importRule whenExport:(ExportRuleBlock)exportRule;
- (void)reworkRuleForKeyPath:(NSString *)keyPath whenImport:(ImportRuleBlock)importRule whenExport:(ExportRuleBlock)exportRule;

- (void)removeAllObjects;

@end
