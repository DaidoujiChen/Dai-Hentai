//
//  SearchHintCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/6.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SearchHintCell.h"
#import "Translator.h"

@implementation SearchHintCell

#pragma mark - Private Instance Method

#pragma mark * Method Need to Override

- (void)setSearchValue:(NSArray<NSString *> *)values {
    NSString *originText = [Translator remove:self.textLabel.text];
    if ([values containsObject:originText]) {
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
        NSString *originText = [Translator remove:self.textLabel.text];
        [self onValueChange](originText);
    }
}

@end
