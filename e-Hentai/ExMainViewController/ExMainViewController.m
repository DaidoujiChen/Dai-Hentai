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

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, readonly) NSString *exFilterString;

@end

@implementation ExMainViewController

#pragma mark - dynamic

- (NSString *)exFilterString {
    NSMutableString *filterURLString = [NSMutableString stringWithFormat:@"http://exhentai.org//?page=%lu", (unsigned long)self.listIndex];
    NSArray *filters = HentaiPrefer[@"filtersFlag"];
    
    //建立過濾 url
    for (NSInteger i = 0; i < [HentaiFilters count]; i++) {
        NSNumber *eachFlag = filters[i];
        if ([eachFlag boolValue]) {
            [filterURLString appendFormat:@"&%@", HentaiFilters[i][@"url"]];
        }
    }
    
    //去除掉空白換行字符後, 如果長度不為 0, 則表示有字
    NSCharacterSet *emptyCharacter = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[HentaiPrefer[@"searchText"] componentsSeparatedByCharactersInSet:emptyCharacter] componentsJoinedByString:@""].length) {
        [filterURLString appendFormat:@"&f_search=%@", HentaiPrefer[@"searchText"]];
    }
    [filterURLString appendString:@"&f_apply=Apply+Filter"];
    return [filterURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        UITextField *username = [alertView textFieldAtIndex:0];
        UITextField *password = [alertView textFieldAtIndex:1];
        alertView.hentai_account(username.text, password.text);
    }
}

#pragma mark - private

//把 request 的判斷都放到這個 method 裡面來
- (void)loadList:(void (^)(BOOL successed, NSArray *listArray))completion {
    [HentaiParser requestListAtFilterUrl:self.exFilterString forExHentai:YES completion: ^(HentaiParserStatus status, NSArray *listArray) {
        if (status && [listArray count]) {
            completion(YES, listArray);
        }
        else {
            completion(NO, nil);
        }
    }];
}

#pragma mark - life cycle

- (id)init {
    if (isIPad) {
        self = [super initWithNibName:@"IPadMainViewController" bundle:nil];
    }
    else {
        self = [super initWithNibName:@"MainViewController" bundle:nil];
    }
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if (HentaiAccount[@"UserName"]) {
        [DaiInboxHUD showMessage:[[NSAttributedString alloc] initWithString:@"潛入 exHentai 中..."]];
        [DiveExHentai diveByUserName:HentaiAccount[@"UserName"] password:HentaiAccount[@"Password"] completion: ^(BOOL isSuccess) {
            if (isSuccess) {
                [super viewWillAppear:animated];
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
            }
            [DaiInboxHUD hide];
        }];
    }
    else {
        UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"登入" message:@"輸入您可進入 exhentai 的帳號" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        loginAlert.hentai_account = ^(NSString *userName, NSString *password) {
            [DaiInboxHUD showMessage:[[NSAttributedString alloc] initWithString:@"潛入 exHentai 中..."]];
            [DiveExHentai diveByUserName:userName password:password completion: ^(BOOL isSuccess) {
                if (isSuccess) {
                    [LightWeightPlist lwpSafe:^{
                        HentaiAccount[@"UserName"] = userName;
                        HentaiAccount[@"Password"] = password;
                        LWPForceWrite();
                    }];
                    [super viewWillAppear:animated];
                }
                else {
                    [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
                }
                [DaiInboxHUD hide];
            }];
        };
        [loginAlert addButtonWithTitle:@"Go~ O3O"];
        [loginAlert show];
    }
}

@end
