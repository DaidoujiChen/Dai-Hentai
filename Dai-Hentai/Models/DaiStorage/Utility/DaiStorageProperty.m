//
//  DaiStorageProperty.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStorageProperty.h"
#import <objc/runtime.h>

@interface SelectorCache : NSObject

@property Class cacheClass;
@property SEL cacheSelector;

@end

@implementation SelectorCache

@end

@interface DaiStorageProperty ()

@property Class propertyClass;
@property SEL setter;
@property SEL getter;
@property SEL importName;
@property SEL importType;
@property SEL exportName;
@property SEL exportType;

@end

@implementation DaiStorageProperty

- (Class)propertyClass {
    if (!self.type) {
        return nil;
    }
    
    if (!_propertyClass) {
        _propertyClass = [self classFromCache:self.type];
    }
    return _propertyClass;
}

- (SEL)setter {
    if (!self.name) {
        return nil;
    }
    
    if (!_setter) {
        _setter = [self setterFromCache:self.name];
    }
    return _setter;
}

- (SEL)getter {
    if (!self.name) {
        return nil;
    }
    
    if (!_getter) {
        _getter = [self getterFromCache:self.name];
    }
    return _getter;
}

- (SEL)importName {
    if (!self.name) {
        return nil;
    }
    
    if (!_importName) {
        _importName = [self importSelectorFromCache:self.name];
    }
    return _importName;
}

- (SEL)importType {
    if (!self.type) {
        return nil;
    }
    
    if (!_importType) {
        _importType = [self importSelectorFromCache:self.type];
    }
    return _importType;
}

- (SEL)exportName {
    if (!self.name) {
        return nil;
    }
    
    if (!_exportName) {
        _exportName = [self exportSelectorFromCache:self.name];
    }
    return _exportName;
}

- (SEL)exportType {
    if (!self.type) {
        return nil;
    }
    
    if (!_exportType) {
        _exportType = [self exportSelectorFromCache:self.type];
    }
    return _exportType;
}

#pragma mark - private instance method

- (Class)classFromCache:(NSString *)className {
    if ([DaiStorageProperty classCache][className]) {
        SelectorCache *selectorCache = [DaiStorageProperty classCache][className];
        return selectorCache.cacheClass;
    }
    else {
        SelectorCache *selectorCache = [SelectorCache new];
        selectorCache.cacheClass = NSClassFromString(className);
        [DaiStorageProperty classCache][className] = selectorCache;
        return selectorCache.cacheClass;
    }
}

- (SEL)setterFromCache:(NSString *)name {
    if ([DaiStorageProperty setterCache][name]) {
        SelectorCache *selectorCache = [DaiStorageProperty setterCache][name];
        return selectorCache.cacheSelector;
    }
    else {
        SelectorCache *selectorCache = [SelectorCache new];
        NSString *selectorName = [NSString stringWithFormat:@"set%@%@:", [[name substringToIndex:1] uppercaseString], [name substringFromIndex:1]];
        selectorCache.cacheSelector = NSSelectorFromString(selectorName);
        [DaiStorageProperty setterCache][name] = selectorCache;
        return selectorCache.cacheSelector;
    }
}

- (SEL)getterFromCache:(NSString *)name {
    if ([DaiStorageProperty getterCache][name]) {
        SelectorCache *selectorCache = [DaiStorageProperty getterCache][name];
        return selectorCache.cacheSelector;
    }
    else {
        SelectorCache *selectorCache = [SelectorCache new];
        selectorCache.cacheSelector = NSSelectorFromString(name);
        [DaiStorageProperty getterCache][name] = selectorCache;
        return selectorCache.cacheSelector;
    }
}

- (SEL)importSelectorFromCache:(NSString *)name {
    if ([DaiStorageProperty importSelectorCache][name]) {
        SelectorCache *selectorCache = [DaiStorageProperty importSelectorCache][name];
        return selectorCache.cacheSelector;
    }
    else {
        SelectorCache *selectorCache = [SelectorCache new];
        NSString *selectorString = [NSString stringWithFormat:@"daiStorage_ruleImport_%@:", name];
        selectorCache.cacheSelector = NSSelectorFromString(selectorString);
        [DaiStorageProperty importSelectorCache][name] = selectorCache;
        return selectorCache.cacheSelector;
    }
}

- (SEL)exportSelectorFromCache:(NSString *)name {
    if ([DaiStorageProperty exportSelectorCache][name]) {
        SelectorCache *selectorCache = [DaiStorageProperty exportSelectorCache][name];
        return selectorCache.cacheSelector;
    }
    else {
        SelectorCache *selectorCache = [SelectorCache new];
        NSString *selectorString = [NSString stringWithFormat:@"daiStorage_ruleExport_%@:", name];
        selectorCache.cacheSelector = NSSelectorFromString(selectorString);
        [DaiStorageProperty exportSelectorCache][name] = selectorCache;
        return selectorCache.cacheSelector;
    }
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

#pragma mark - private class method

+ (NSMutableDictionary *)importSelectorCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableDictionary *)exportSelectorCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableDictionary *)classCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableDictionary *)setterCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableDictionary *)getterCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

@end
