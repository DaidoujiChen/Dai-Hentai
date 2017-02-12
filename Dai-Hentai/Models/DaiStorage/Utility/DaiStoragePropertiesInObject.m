//
//  DaiStoragePropertiesInObject.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStoragePropertiesInObject.h"
#import <objc/runtime.h>

@implementation DaiStoragePropertiesInObject

#pragma mark - class method

//http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
//列出當前 class 含有的 property 有哪些
+ (NSArray *)enumerate:(id)anObject {
    NSMutableArray *propertyNames = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([anObject class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName) {
            NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
            NSString *propertyType = [self readableTypeForEncoding:[self attributesDictionaryForProperty:property][@"T"]];
            if (!NSClassFromString(propertyType)) {
                [self registerClass:propertyType];
            }
            [propertyNames addObject:[DaiStorageProperty propertyName:propertyName type:propertyType]];
        }
    }
    free(properties);
    return propertyNames;
}

#pragma mark - private class method

+ (void)registerClass:(NSString *)className {
	Class superclass = (Class)objc_getClass("DaiStorageArray");
	Class newClass = objc_allocateClassPair(superclass, [className UTF8String], 0);
    __unsafe_unretained Protocol *newProtocol = objc_getProtocol([[self splitToProtocol:className] UTF8String]);
    if (!newProtocol) {
        newProtocol = objc_allocateProtocol([[self splitToProtocol:className] UTF8String]);
        objc_registerProtocol(newProtocol);
    }
    class_addProtocol(newClass, newProtocol);
	objc_registerClassPair(newClass);
}

+ (NSString *)splitToProtocol:(NSString *)name {
    NSRange range = [name rangeOfString:@"Array"];
    return [name substringToIndex:range.location];
}

#pragma mark * list properties in class

// from FLEX FLEXRuntimeUtility
+ (NSDictionary *)attributesDictionaryForProperty:(objc_property_t)property {
    NSString *attributes = @(property_getAttributes(property));
    return [self attributesFromCache:attributes];
}

// from FLEX FLEXRuntimeUtility
+ (NSString *)readableTypeForEncoding:(NSString *)encodingString {
    if (!encodingString) {
        return nil;
    }
    
    NSString *readableString = [self encodingFromCache:encodingString];
    if (readableString) {
        return readableString;
    }
    NSAssert(0, @"Only Support NSObject subclass");
    return nil;
}

#pragma mark * cache

+ (NSDictionary *)attributesFromCache:(NSString *)attributes {
    if ([self propertiesDictionaryCache][attributes]) {
        return [self propertiesDictionaryCache][attributes];
    }
    else {
        NSArray *attributePairs = [attributes componentsSeparatedByString:@","];
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionaryWithCapacity:[attributePairs count]];
        for (NSString *attributePair in attributePairs) {
            [attributesDictionary setObject:[attributePair substringFromIndex:1] forKey:[attributePair substringToIndex:1]];
        }
        [self propertiesDictionaryCache][attributes] = attributesDictionary;
        return attributesDictionary;
    }
}

+ (NSString *)encodingFromCache:(NSString *)encodingString {
    if ([self encodingCache][encodingString]) {
        return [self encodingCache][encodingString];
    }
    else {
        const char *encodingCString = [encodingString UTF8String];
        if (encodingCString[0] == '@') {
            NSString *class = [encodingString substringFromIndex:1];
            class = [class stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if ([class length] == 0 || [class isEqual:@"?"]) {
                class = @"id";
            } else {
                class = [class stringByAppendingString:@""];
            }
            [self encodingCache][encodingString] = class;
            return class;
        }
    }
    return nil;
}

#pragma mark * runtime objects

+ (NSMutableDictionary *)propertiesDictionaryCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableDictionary *)encodingCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

@end
