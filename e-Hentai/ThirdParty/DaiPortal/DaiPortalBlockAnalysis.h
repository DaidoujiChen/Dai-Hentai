//
//  DaiPortalBlockAnalysis.h
//  DaiPortal
//
//  Created by 啟倫 陳 on 2014/11/18.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

//https://github.com/mikeash/MABlockForwarding
//用來檢測 block 裡面包含的參數數量

typedef enum {
    DaiPortalBlockAnalysisReturnTypeID,
    DaiPortalBlockAnalysisReturnTypeVoid,
    DaiPortalBlockAnalysisReturnTypeUnknow
} DaiPortalBlockAnalysisReturnType;

#import <Foundation/Foundation.h>

@interface DaiPortalBlockAnalysis : NSObject

+ (NSUInteger)argumentsInBlock:(id)blockObj;
+ (DaiPortalBlockAnalysisReturnType)returnTypeInBlock:(id)blockObj;

@end
