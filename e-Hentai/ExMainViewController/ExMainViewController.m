//
//  ExMainViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/16.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "ExMainViewController.h"
#import "DiveExHentaiV2.h"

@interface LoginWebViewController : UIViewController

@property (nonatomic, strong) NSTimer *checkTimer;

@end

@implementation LoginWebViewController

#pragma mark - login check

- (void)checkingLoop {
    [DiveExHentaiV2 replaceCookies];
    if ([DiveExHentaiV2 checkCookie]) {
        [self cancelAction];
    }
}

#pragma mark - navigation bar button action

- (void)cancelAction {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion: ^{
        @strongify(self);
        [self.checkTimer invalidate];
    }];
}

#pragma mark - setup inits

- (void)setupInitValues {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    // 開一個登入網頁
    UIWebView *loginWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://forums.e-hentai.org/index.php?act=Login&CODE=01"]]];
    [self.view addSubview:loginWebView];
    
    // 用一個 timer 等到有正確的 cookie
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkingLoop) userInfo:nil repeats:YES];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
}

@end

@interface ExMainViewController ()

@property (nonatomic, assign) NSUInteger listIndex;
@property (nonatomic, assign) BOOL onceFlag;
@property (nonatomic, assign) BOOL exOnceFlag;

@end

@implementation ExMainViewController

#pragma mark - private

- (void)presentLoginWebView {
    LoginWebViewController *loginWebViewController = [LoginWebViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginWebViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

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
        
        if ([DiveExHentaiV2 checkCookie]) {
            avoidPerformSelectorWarning([self performSelector:@selector(reloadDatas)];)
        }
        else if ([Account shared].username) {
            [SVProgressHUD show];
            @weakify(self);
            [DiveExHentaiV2 diveBy:[Account shared].username andPassword:[Account shared].password completion: ^(BOOL isSuccess) {
                @strongify(self);
                if (isSuccess) {
                    avoidPerformSelectorWarning([self performSelector:@selector(reloadDatas)];)
                }
                else {
                    @weakify(self);
                    [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:nil cancelButtonTitle:@"好吧~ Q3Q" otherButtonTitles:@[ @"或許我可以試試 WebView O3O" ] onClickIndex: ^(UIAlertView *alertView, NSInteger clickIndex) {
                        @strongify(self);
                        [self presentLoginWebView];
                    } onCancel: nil];
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
                [DiveExHentaiV2 diveBy:username.text andPassword:password.text completion: ^(BOOL isSuccess) {
                    @strongify(self);
                    if (isSuccess) {
                        [Account shared].username = username.text;
                        [Account shared].password = password.text;
                        [[Account shared] sync];
                        avoidPerformSelectorWarning([self performSelector:@selector(reloadDatas)];)
                    }
                    else {
                        @weakify(self);
                        [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:nil cancelButtonTitle:@"好吧~ Q3Q" otherButtonTitles:@[ @"或許我可以試試 WebView O3O" ] onClickIndex: ^(UIAlertView *alertView, NSInteger clickIndex) {
                            @strongify(self);
                            [self presentLoginWebView];
                        } onCancel: nil];
                    }
                    [SVProgressHUD dismiss];
                }];
            } onCancel:nil];
        }
    }
}

@end
