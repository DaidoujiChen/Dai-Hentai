//
//  LoginViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/4.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "LoginViewController.h"
#import "Dai_Hentai-Swift.h"

@interface LoginWebViewController ()

@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, copy) void (^completion)(void);

@end

@implementation LoginWebViewController

#pragma mark - Private Instance Method

#pragma mark * Check Cookies

- (void)checkingLoop {
    if ([ExCookie isExist]) {
        if (self.completion) {
            self.completion();
        }
        [self cancelAction];
    }
}

#pragma mark * Init

- (void)cancelAction {
    __weak LoginWebViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion: ^{
        if (!weakSelf) {
            return;
        }
        __strong LoginWebViewController *strongSelf = weakSelf;
        [strongSelf.checkTimer invalidate];
    }];
}

- (void)initValues {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    // 開一個登入網頁
    UIWebView *loginWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://forums.e-hentai.org/index.php?act=Login&CODE=01"]]];
    [self.view addSubview:loginWebView];
    
    // 用一個 timer 等到有正確的 cookie
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkingLoop) userInfo:nil repeats:YES];
}

#pragma mark - Life Cycle

- (instancetype)initWithCompletion:(void (^)(void))completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

@end
