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
@property (nonatomic, assign) BOOL onceFlag;
@property (nonatomic, assign) BOOL exOnceFlag;

@end

@implementation ExMainViewController

#pragma mark - dynamic

- (NSString *)filterString {
    avoidPerformSelectorWarning(NSString *filterString = [self performSelector:@selector(filterDependOnURL:) withObject:@"http://exhentai.org//?page=%lu"];)
    return filterString;
}

- (BOOL) isExHentai {
    return YES;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.onceFlag = NO;
    self.exOnceFlag = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.exOnceFlag) {
        self.exOnceFlag = NO;
        if ([Account shared].username) {
            [SVProgressHUD show];
            @weakify(self);
            [DiveExHentai diveByUserName:[Account shared].username password:[Account shared].password completion: ^(BOOL isSuccess) {
                @strongify(self);
                if (isSuccess) {
                    avoidPerformSelectorWarning([self performSelector:@selector(reloadDatas)];)
                }
                else {
                    [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
                }
                [SVProgressHUD dismiss];
            }];
        }
        else {
            @weakify(self);
            [UIAlertView hentai_alertViewWithTitle:@"登入" message:@"輸入您可進入 exhentai 的帳號" style:UIAlertViewStyleLoginAndPasswordInput willPresent:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"Go~ O3O"] onClickIndex: ^(UIAlertView *alertView, NSInteger clickIndex) {
                UITextField *username = [alertView textFieldAtIndex:0];
                UITextField *password = [alertView textFieldAtIndex:1];
                
                [SVProgressHUD show];
                [DiveExHentai diveByUserName:username.text password:password.text completion: ^(BOOL isSuccess) {
                    @strongify(self);
                    if (isSuccess) {
                        [Account shared].username = username.text;
                        [Account shared].password = password.text;
                        [[Account shared] sync];
                        avoidPerformSelectorWarning([self performSelector:@selector(reloadDatas)];)
                    }
                    else {
                        [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
                    }
                    [SVProgressHUD dismiss];
                }];
            } onCancel:nil];
        }
    }
}

@end
