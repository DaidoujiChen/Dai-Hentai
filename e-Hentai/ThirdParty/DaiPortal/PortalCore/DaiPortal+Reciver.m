//
//  DaiPortal+Reciver.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/11.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiPortal+Reciver.h"

#import "DaiPortal+Internal.h"

@implementation DaiPortal (Reciver)

- (void)recv:(VoidBlock)aBlock {
    [self defaultReciver:aBlock];
}

- (void)recv_warp:(VoidBlock)aBlock {
    [self recv:aBlock];
    self.isWarp = YES;
}

- (void)respond:(PackageBlock)aBlock {
    [self defaultReciver:aBlock];
}

- (void)respond_warp:(PackageBlock)aBlock {
    [self respond:aBlock];
    self.isWarp = YES;
}

#pragma mark - private

- (void)defaultReciver:(id)aBlock {
    self.isWarp = NO;
    [self signPortal:aBlock];
}

@end
