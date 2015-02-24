//
//  SFExecuteOnDeallocInternalObject.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/10.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

//https://github.com/krzysztofzablocki/NSObject-SFExecuteOnDealloc
//用來檢測物件是否 dealloc

#import <Foundation/Foundation.h>

@interface SFExecuteOnDeallocInternalObject : NSObject

@property (nonatomic, copy) void (^block)();

- (id)initWithBlock:(void (^)(void))aBlock;

@end
