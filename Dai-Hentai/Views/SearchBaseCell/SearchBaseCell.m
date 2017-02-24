//
//  SearchBaseCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/23.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "SearchBaseCell.h"

@interface SearchBaseCell ()

@property (nonatomic, copy) void (^change)(id newValue);

@end

@implementation SearchBaseCell

#pragma mark - Private Instance Method

#pragma mark * Method Need to Override

- (void)setSearchValue:(id)value {
    NSAssert(0, @"You Must Implement This Method in Subclass");
}

#pragma mark - Instance Method

- (void)setSeachValue:(id)value onChange:(void (^)(id newValue))change {
    self.change = change;
    [self setSearchValue:value];
}

- (void (^)(id newValue))onValueChange {
    __weak SearchBaseCell *weakSelf = self;
    return ^(id newValue) {
        if (weakSelf && weakSelf.change) {
            __strong SearchBaseCell *strongSelf = weakSelf;
            strongSelf.change(newValue);
        }
    };
}

@end
