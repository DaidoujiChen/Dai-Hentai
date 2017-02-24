//
//  SearchCategoryCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/23.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "SearchCategoryCell.h"

@implementation SearchCategoryCell

#pragma mark - Private Instance Method

#pragma mark * Method Need to Override

- (void)setSearchValue:(NSNumber *)value {
    if (value.boolValue) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        if (self.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.accessoryType = UITableViewCellAccessoryNone;
            [self onValueChange](@(NO));
        }
        else {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
            [self onValueChange](@(YES));
        }
    }
}

@end
