//
//  DaiStorageArray.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/10.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStorageArray.h"
#import <objc/runtime.h>

@interface DaiStorageArray ()

@property (nonatomic, strong) NSMutableArray *internalArray;
@property (nonatomic, strong) NSString *aClassName;

@end

@implementation DaiStorageArray

- (Class)aClass {
    NSAssert(self.aClassName, @"請先設定 class");
	return NSClassFromString(self.aClassName);
}

#pragma mark - Methods to Override

#pragma mark * NSArray

- (NSUInteger)count {
	NSAssert(self.aClassName, @"請先設定 class");
	return self.internalArray.count;
}

- (id)objectAtIndex:(NSUInteger)index {
	NSAssert(self.aClassName, @"請先設定 class");
	return self.internalArray[index];
}

#pragma mark * NSMutableArray

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
	NSAssert(self.aClassName, @"請先設定 class");
	[self.internalArray insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	NSAssert(self.aClassName, @"請先設定 class");
	[self.internalArray removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
	NSAssert(self.aClassName, @"請先設定 class");
	[self.internalArray addObject:anObject];
}

- (void)removeLastObject {
	NSAssert(self.aClassName, @"請先設定 class");
	[self.internalArray removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	NSAssert(self.aClassName, @"請先設定 class");
	[self.internalArray replaceObjectAtIndex:index withObject:anObject];
}

#pragma mark - private instance method

- (void)autoSetupClass {
    Class cls = [self class];
    unsigned count;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(cls, &count);
    if (count) {
        self.aClassName = [NSString stringWithUTF8String:protocol_getName(protocols[0])];
    }
    free(protocols);
}

#pragma mark - life cycle

- (id)init {
	self = [super init];
	if (self) {
        [self autoSetupClass];
		self.internalArray = [NSMutableArray array];
	}
	return self;
}

@end
