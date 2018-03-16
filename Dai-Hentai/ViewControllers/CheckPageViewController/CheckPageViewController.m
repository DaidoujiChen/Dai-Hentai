//
//  CheckPageViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/10.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "CheckPageViewController.h"

@interface CheckPageViewController ()

@property (nonatomic, strong) NSString *urlString;

@end

@implementation CheckPageViewController

#pragma mark * Init

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initValues {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    // 開一個頁面
    UIWebView *checkWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [checkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    [self.view addSubview:checkWebView];
}

#pragma mark - Life Cycle

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        self.urlString = urlString;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

@end
