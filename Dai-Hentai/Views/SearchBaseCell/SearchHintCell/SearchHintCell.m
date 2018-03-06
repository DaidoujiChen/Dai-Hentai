//
//  SearchHintCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/6.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SearchHintCell.h"

@implementation SearchHintCell

#pragma mark - Private Instance Method

#pragma mark * Method Need to Override

- (void)setSearchValue:(NSArray<NSString *> *)values {
    if ([values containsObject:self.textLabel.text]) {
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
        }
        else {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        [self onValueChange](self.textLabel.text);
    }
}

@end
