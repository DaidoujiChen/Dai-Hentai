//
//  CheckExViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/10.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "CheckExViewController.h"

@implementation CheckExViewController

#pragma mark * Init

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initValues {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    // 開一個 Ex 頁面
    UIWebView *checkExWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [checkExWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://exhentai.org/"]]];
    [self.view addSubview:checkExWebView];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

@end
