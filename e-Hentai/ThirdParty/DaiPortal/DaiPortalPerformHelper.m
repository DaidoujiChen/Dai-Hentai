//
//  DaiPortalPerformHelper.m
//  DaiPortal
//
//  Created by 啟倫 陳 on 2014/11/18.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiPortalPerformHelper.h"

@implementation DaiPortalPerformHelper

+ (id)idPerformObjects:(NSArray *)objects usingBlock:(id)block {
    switch ([objects count]) {
        case 0:
        {
            id (^performBlock)() = block;
            return performBlock();
        }
            
        case 1:
        {
            id (^performBlock)(id) = block;
            return performBlock(objects[0]);
        }
            
        case 2:
        {
            id (^performBlock)(id, id) = block;
            return performBlock(objects[0], objects[1]);
        }
            
        case 3:
        {
            id (^performBlock)(id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2]);
        }
            
        case 4:
        {
            id (^performBlock)(id, id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2], objects[3]);
        }
            
        case 5:
        {
            id (^performBlock)(id, id, id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2], objects[3], objects[4]);
        }
            
        case 6:
        {
            id (^performBlock)(id, id, id, id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5]);
        }
            
        case 7:
        {
            id (^performBlock)(id, id, id, id, id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5], objects[6]);
        }
            
        case 8:
        {
            id (^performBlock)(id, id, id, id, id, id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5], objects[6], objects[7]);
        }
            
        case 9:
        {
            id (^performBlock)(id, id, id, id, id, id, id, id, id) = block;
            return performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5], objects[6], objects[7], objects[8]);
        }
            
        default:
        {
            NSLog(@"參數太多了, 沒有支援囉");
            return nil;
        }
    }
}

+ (void)voidPerformObjects:(NSArray *)objects usingBlock:(id)block {
    switch ([objects count]) {
        case 0:
        {
            void (^performBlock)() = block;
            performBlock();
            break;
        }
            
        case 1:
        {
            void (^performBlock)(id) = block;
            performBlock(objects[0]);
            break;
        }
            
        case 2:
        {
            void (^performBlock)(id, id) = block;
            performBlock(objects[0], objects[1]);
            break;
        }
            
        case 3:
        {
            void (^performBlock)(id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2]);
            break;
        }
            
        case 4:
        {
            void (^performBlock)(id, id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2], objects[3]);
            break;
        }
            
        case 5:
        {
            void (^performBlock)(id, id, id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2], objects[3], objects[4]);
            break;
        }
            
        case 6:
        {
            void (^performBlock)(id, id, id, id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5]);
            break;
        }
            
        case 7:
        {
            void (^performBlock)(id, id, id, id, id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5], objects[6]);
            break;
        }
            
        case 8:
        {
            void (^performBlock)(id, id, id, id, id, id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5], objects[6], objects[7]);
            break;
        }
            
        case 9:
        {
            void (^performBlock)(id, id, id, id, id, id, id, id, id) = block;
            performBlock(objects[0], objects[1], objects[2], objects[3], objects[4], objects[5], objects[6], objects[7], objects[8]);
            break;
        }
            
        default:
            NSLog(@"參數太多了, 沒有支援囉");
            break;
    }
}

@end
