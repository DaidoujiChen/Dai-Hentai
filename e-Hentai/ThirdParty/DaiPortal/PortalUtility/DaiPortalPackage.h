//
//  DaiPortalPackage.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/10.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

//為了統一傳進跟回傳的東西, 所以用一個固定的格式來規範

#import <Foundation/Foundation.h>

#import "DaiPortalMetaMacros.h"

@interface DaiPortalPackageNil : NSObject

+ (DaiPortalPackageNil *)nilObject;

@end

@interface DaiPortalPackage : NSObject

@property (nonatomic, readonly) id anyObject;

//空的包包, 什麼都沒有
+ (DaiPortalPackage *)empty;

//只有一個物件
+ (DaiPortalPackage *)item:(id)anItem;

//很多的物件
+ (DaiPortalPackage *)itemsFromArray:(NSArray *)objects;

@end

#define DaiPortalPackageItems(...) \
    ([DaiPortalPackage itemsFromArray:@[metamacro_foreach(checkIfNil, , __VA_ARGS__)]])

#define DaiPortalPackageItem(ARG) \
    ([DaiPortalPackage item:((ARG) ? : [DaiPortalPackageNil nilObject])])

#define DaiPortalPackageEmpty \
    ([DaiPortalPackage empty])

#define checkIfNil(INDEX, ARG) \
    (ARG) ? : [DaiPortalPackageNil nilObject],
