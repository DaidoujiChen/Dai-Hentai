//
//  SearchRatingCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/23.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "SearchRatingCell.h"

@interface SearchRatingCell ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *ratingSegment;

@end

@implementation SearchRatingCell

#pragma mark - Private Instance Method

#pragma mark * Method Need to Override

- (void)setSearchValue:(NSNumber *)value {
    self.ratingSegment.selectedSegmentIndex = value.integerValue;
}

#pragma mark - IBAction

- (IBAction)onRatingChangeAction:(UISegmentedControl *)sender {
    [self onValueChange](@(sender.selectedSegmentIndex));
}

@end
