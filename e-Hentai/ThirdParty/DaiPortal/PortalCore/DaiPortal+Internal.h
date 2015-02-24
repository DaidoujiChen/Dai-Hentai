//
//  DaiPortal+Internal.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/11.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiPortal.h"

#import "DaiPortalBlockAnalysis.h"

@interface DaiPortal (Internal)

@property (nonatomic, copy) id actionBlock;
@property (nonatomic, readonly) NSUInteger argumentsInBlock;
@property (nonatomic, readonly) DaiPortalBlockAnalysisReturnType returnTypeInBlock;
@property (nonatomic, readonly) NSString *resultPortalIdentifier;
@property (nonatomic, readonly) BOOL isDisposable;
@property (nonatomic, assign) BOOL isWarp;

- (void)deallocObserver;
- (void)signPortal:(id)block;
- (void)broadcastPackage:(DaiPortalPackage *)package;

@end
