//
//  CategoryItem.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/24.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "CategoryItem.h"

@interface CategoryItem ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *getterString;

@end

@implementation CategoryItem

#pragma mark - Class Method

+ (instancetype)itemWith:(NSString *)title getter:(NSString *)getter {
    return [[CategoryItem alloc] initWith:title getter:getter];
}

#pragma mark - Readonly Properties

- (SEL)getterSEL {
    return NSSelectorFromString(self.getterString);
}

- (SEL)setterSEL {
    return NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [self.getterString substringToIndex:1].uppercaseString, [self.getterString substringFromIndex:1]]);
}

#pragma mark - Life Cycle

- (instancetype)initWith:(NSString *)title getter:(NSString *)getter {
    self = [super init];
    if (self) {
        self.title = title;
        self.getterString = getter;
    }
    return self;
}

@end
