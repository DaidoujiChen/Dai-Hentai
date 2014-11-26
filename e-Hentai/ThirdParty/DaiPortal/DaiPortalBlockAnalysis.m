//
//  DaiPortalBlockAnalysis.m
//  DaiPortal
//
//  Created by 啟倫 陳 on 2014/11/18.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiPortalBlockAnalysis.h"

struct BlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
};

struct Block {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct BlockDescriptor *descriptor;
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26),
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29),
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

@implementation DaiPortalBlockAnalysis

+ (NSUInteger)argumentsInBlock:(id)blockObj {
    struct Block *block = (__bridge void *)blockObj;
    struct BlockDescriptor *descriptor = block->descriptor;
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    int index = 0;
    if (block->flags & BLOCK_HAS_COPY_DISPOSE) {
        index += 2;
    }
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descriptor->rest[index]];
    return [signature numberOfArguments];
}

+ (DaiPortalBlockAnalysisReturnType)returnTypeInBlock:(id)blockObj {
    struct Block *block = (__bridge void *)blockObj;
    struct BlockDescriptor *descriptor = block->descriptor;
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    int index = 0;
    if (block->flags & BLOCK_HAS_COPY_DISPOSE) {
        index += 2;
    }
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descriptor->rest[index]];
    if (strncmp(signature.methodReturnType, "@", 1) == 0) {
        return DaiPortalBlockAnalysisReturnTypeID;
    }
    else if (strncmp(signature.methodReturnType, "v", 1) == 0) {
        return DaiPortalBlockAnalysisReturnTypeVoid;
    }
    else {
        return DaiPortalBlockAnalysisReturnTypeUnknow;
    }
}

@end
