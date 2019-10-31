//
//  SettingViewController+LoginUsingCookie.m
//  Dai-Hentai
//
//  Created by David Dai on 10/16/19.
//  Copyright © 2019 DaidoujiChen. All rights reserved.
//

#import "SettingViewController+ListAndAPIStatus.h"
#import "Dai_Hentai-Swift.h"

@implementation SettingViewController (LoginUsingExKey)

- (void)onLoginUsingExKeyPress {
    UIAlertController *loginCookieAlert = [UIAlertController alertControllerWithTitle:@"用Cookie登錄" message:@"請在此處輸入Cookie" preferredStyle:UIAlertControllerStyleAlert];
    
    [loginCookieAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self; // 此為填寫Cookie的地方
        self.cookieTextField = textField; // 使此Textfield 外部可訪問
    }];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *cookieString = self.cookieTextField.text;
        [self addLoginCookie: cookieString];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [loginCookieAlert addAction:cancel];
    [loginCookieAlert addAction:ok];
    [self presentViewController:loginCookieAlert animated:YES completion:nil];
}

#pragma mark - Private Method

- (void)addLoginCookie: (NSString*)exKey {
    if (([exKey length] == 0) || (![[exKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])) { // Cookie 為空
        return;
    }
    
    
    [ExCookie clean];
    [ExCookie manuallyAddCookieWithExKey:exKey];
    [self displayListAndAPIStatus]; // 刷新API狀態
    for (UINavigationController *controller in self.tabBarController.viewControllers) {
        SEL resetButtonAndParser = NSSelectorFromString(@"resetButtonAndParser");
        if ([controller.topViewController respondsToSelector:resetButtonAndParser]) {
            [controller.topViewController performSelector:resetButtonAndParser];
        }
    }
}

@end

