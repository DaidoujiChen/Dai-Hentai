//
//  ExMainViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/16.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "ExMainViewController.h"

#import "DiveExHentai.h"

@interface ExMainViewController ()

@property (nonatomic, assign) BOOL onceFlag;

@end

@implementation ExMainViewController

#pragma mark - dynamic

- (NSString *)filterString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSString *filterString = [self performSelector:@selector(filterDependOnURL:) withObject:@"http://exhentai.org//?page=%lu"];
#pragma clang diagnostic pop
    return filterString;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        UITextField *username = [alertView textFieldAtIndex:0];
        UITextField *password = [alertView textFieldAtIndex:1];
        alertView.hentai_account(username.text, password.text);
    }
    else {
        alertView.hentai_account(nil, nil);
    }
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    self.onceFlag = NO;
    [super viewWillAppear:animated];
    
    if ([HentaiSettingManager temporaryHentaiAccount][@"UserName"]) {
        [SVProgressHUD show];
        [DiveExHentai diveByUserName:[HentaiSettingManager temporaryHentaiAccount][@"UserName"] password:[HentaiSettingManager temporaryHentaiAccount][@"Password"] completion: ^(BOOL isSuccess) {
            if (isSuccess) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                [self performSelector:@selector(reloadDatas)];
#pragma clang diagnostic pop
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
            }
            [SVProgressHUD dismiss];
        }];
    }
    else {
        UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"登入" message:@"輸入您可進入 exhentai 的帳號" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        loginAlert.hentai_account = ^(NSString *userName, NSString *password) {
            [SVProgressHUD show];
            [DiveExHentai diveByUserName:userName password:password completion: ^(BOOL isSuccess) {
                if (isSuccess) {
                    [HentaiSettingManager temporaryHentaiAccount][@"UserName"] = userName;
                    [HentaiSettingManager temporaryHentaiAccount][@"Password"] = password;
                    [HentaiSettingManager storeHentaiAccount];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    [self performSelector:@selector(reloadDatas)];
#pragma clang diagnostic pop
                }
                else {
                    [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
                }
                [SVProgressHUD dismiss];
            }];
        };
        [loginAlert addButtonWithTitle:@"Go~ O3O"];
        [loginAlert show];
    }
}

@end
