//
//  SearchKeywordCell.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/23.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "SearchKeywordCell.h"

@interface SearchKeywordCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchKeywordTextField;

@end

@implementation SearchKeywordCell

#pragma mark - Private Instance Method

#pragma mark * Method Need to Override

- (void)setSearchValue:(NSString *)value {
    self.searchKeywordTextField.text = value;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self onValueChange]([textField.text stringByReplacingCharactersInRange:range withString:string]);
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self onValueChange](@"");
    return YES;
}

#pragma mark - Life Cycle

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        self.searchKeywordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
}

@end
