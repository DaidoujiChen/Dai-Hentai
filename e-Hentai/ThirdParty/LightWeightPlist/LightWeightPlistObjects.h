//
//  LightWeightPlistObjects.h
//  LightWeightPlist
//
//  Created by 啟倫 陳 on 2014/6/10.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LightWeightPlistObjects : NSObject

@property (nonatomic, strong) NSCache *dataCache;
@property (nonatomic, strong) NSMutableDictionary *pointerMapping;

@end
