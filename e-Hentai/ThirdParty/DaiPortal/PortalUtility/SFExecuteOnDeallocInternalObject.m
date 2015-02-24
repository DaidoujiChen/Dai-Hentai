//
//  SFExecuteOnDeallocInternalObject.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/10.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "SFExecuteOnDeallocInternalObject.h"

@implementation SFExecuteOnDeallocInternalObject

- (id)initWithBlock:(void (^)(void))aBlock {
    self = [super init];
    if (self) {
        self.block = aBlock;
    }
    return self;
}

- (void)dealloc {
    if (self.block) {
        self.block();
    }
}

@end
