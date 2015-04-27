//
//  DaiStorageProperty.h
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaiStorageProperty : NSObject

+ (DaiStorageProperty *)propertyName:(NSString *)name type:(NSString *)type;
+ (DaiStorageProperty *)propertyName:(NSString *)name;
+ (DaiStorageProperty *)propertyType:(NSString *)type;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, readonly) Class propertyClass;
@property (nonatomic, readonly) SEL setter;
@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) SEL importName;
@property (nonatomic, readonly) SEL importType;
@property (nonatomic, readonly) SEL exportName;
@property (nonatomic, readonly) SEL exportType;

@end
