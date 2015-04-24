//
//  DaiStorageProperty.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStorageProperty.h"

@implementation DaiStorageProperty

@dynamic aClass, setter, getter, importName, importType, exportName, exportType;

#pragma mark - readonly

- (Class)aClass {
	return NSClassFromString(self.type);
}

- (SEL)setter {
	NSString *selectorName = [NSString stringWithFormat:@"set%@%@:", [[self.name substringToIndex:1] uppercaseString], [self.name substringFromIndex:1]];
	return NSSelectorFromString(selectorName);
}

- (SEL)getter {
	return NSSelectorFromString(self.name);
}

- (SEL)importName {
    return [self importSelector:self.name];
}

- (SEL)importType {
    return [self importSelector:self.type];
}

- (SEL)exportName {
    return [self exportSelector:self.name];
}

- (SEL)exportType {
    return [self exportSelector:self.type];
}

#pragma mark - private instance method

- (SEL)importSelector:(NSString *)specialName {
    NSString *selectorString = [NSString stringWithFormat:@"daiStorage_ruleImport%@:", specialName];
    return NSSelectorFromString(selectorString);
}

- (SEL)exportSelector:(NSString *)specialName {
    NSString *selectorString = [NSString stringWithFormat:@"daiStorage_ruleExport%@:", specialName];
    return NSSelectorFromString(selectorString);
}

#pragma mark - class method

+ (DaiStorageProperty *)propertyName:(NSString *)name type:(NSString *)type {
	DaiStorageProperty *newProperty = [DaiStorageProperty new];
	newProperty.name = name;
	newProperty.type = type;
	return newProperty;
}

+ (DaiStorageProperty *)propertyName:(NSString *)name {
	return [self propertyName:name type:nil];
}

+ (DaiStorageProperty *)propertyType:(NSString *)type {
	return [self propertyName:nil type:type];
}

@end
