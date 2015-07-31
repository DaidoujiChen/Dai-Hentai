//
//  DownloadedGroupFilterViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/21.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DownloadedGroupFilterViewController.h"

@interface DownloadedGroupFilterViewController ()

@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation DownloadedGroupFilterViewController

#pragma mark - private instance method

#pragma mark * init

- (QRootElement *)rootMaker {
    [self setupInitValues];
    
    //基本樣貌設定
    QRootElement *root = [QRootElement new];
    root.grouped = YES;
    root.title = @"已下載搜尋條件";
    root.controllerName = @"DownloadedGroupFilterViewController";
    
    //搜尋的 section
    QSection *searchSection = [[QSection alloc] initWithTitle:@"搜尋"];
    
    QLabelElement *remindElement = [[QLabelElement alloc] initWithTitle:@"可能會比原網站的搜尋貧弱!" Value:@""];
    [searchSection addElement:remindElement];
    
    QEntryElement *searchStringElement = [[QEntryElement alloc] initWithTitle:@"搜尋字串" Value:@"" Placeholder:@"也可以什麼都不填"];
    searchStringElement.key = @"searchText";
    [searchSection addElement:searchStringElement];
    [root addSection:searchSection];
    
    //filter section
    QSection *filterGroupSection = [[QSection alloc] initWithTitle:@"Filters"];
    
    NSMutableArray *groupTitles = [NSMutableArray array];
    for (NSDictionary *eachGroupInfo in self.groups) {
        [groupTitles addObject:eachGroupInfo[@"title"]];
    }
    QRadioElement *groupElement = [[QRadioElement alloc] initWithItems:groupTitles selected:0 title:@"在哪一個分類搜尋"];
    groupElement.key = @"group";
    [filterGroupSection addElement:groupElement];
    
    [root addSection:filterGroupSection];
    return root;
}

- (void)setupItemsOnNavigation {
    
    // 設定取消按鈕
    @weakify(self);
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel blockAction: ^{
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // 設定確認按鈕
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone blockAction: ^{
        @strongify(self);
        if (self) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [self.root fetchValueIntoObject:result];
            
            NSMutableDictionary *searchInfo = [NSMutableDictionary dictionary];
            if (![[result[@"searchText"] hentai_withoutSpace] isEqualToString:@""]) {
                NSArray *titles = [result[@"searchText"] componentsSeparatedByString:@" "];
                searchInfo[@"titles"] = titles;
            }
            searchInfo[@"group"] = self.groups[[result[@"group"] integerValue]][@"value"];
            
            [self.delegate onSearchFilterDone:searchInfo];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)setupInitValues {
    self.groups = [NSMutableArray array];
    [self.groups addObject:@{@"title":@"全部", @"value":@""}];
    [self.groups addObject:@{@"title":@"未分類", @"value":[NSNull null]}];
    [self.groups addObjectsFromArray:[HentaiSaveLibrary groups]];
}

#pragma mark - life cycle

- (id)init {
    self = [super initWithRoot:[self rootMaker]];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupItemsOnNavigation];
}

@end
