//
//  SearchFilterV2ViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/13.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "SearchFilterV2ViewController.h"

@interface SearchFilterV2ViewController ()

@end

@implementation SearchFilterV2ViewController

#pragma mark - private

#pragma mark * init

- (QRootElement *)rootMaker {
    //基本樣貌設定
    QRootElement *root = [QRootElement new];
    root.grouped = YES;
    root.title = @"搜尋條件";
    root.controllerName = @"SearchFilterV2ViewController";
    
    //搜尋的 section
    QSection *searchSection = [[QSection alloc] initWithTitle:@"搜尋"];
    QEntryElement *searchStringElement = [[QEntryElement alloc] initWithTitle:@"搜尋字串" Value:[Prefer shared].searchText Placeholder:@"也可以什麼都不填"];
    searchStringElement.key = @"searchText";
    [searchSection addElement:searchStringElement];
    [root addSection:searchSection];
    
    //filter section
    QSection *switchsSection = [[QSection alloc] initWithTitle:@"Filters"];
    
    NSNumber *ratingIndex = [Prefer shared].rating;
    if (!ratingIndex) {
        ratingIndex = @(0);
    }
    QRadioElement *ratingElement = [[QRadioElement alloc] initWithItems:@[@"不限制", @"2星以上", @"3星以上", @"4星以上", @"5星以上"] selected:[ratingIndex intValue] title:@"評價限制"];
    ratingElement.key = @"rating";
    [switchsSection addElement:ratingElement];
    
    for (int i = 0; i < [Prefer shared].flags.count; i++) {
        FilterItem *item = [Filter shared].items[i];
        NSNumber *eachFlag = [Prefer shared].flags[i];
        QBooleanElement *boolElement = [[QBooleanElement alloc] initWithTitle:item.title BoolValue:[eachFlag boolValue]];
        boolElement.key = item.title;
        [switchsSection addElement:boolElement];
    }
    [root addSection:switchsSection];
    
    return root;
}

- (void)setupItemsOnNavigation {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark * actions

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self.root fetchValueIntoObject:result];
    
    for (NSString *eachKey in [result allKeys]) {
        NSUInteger index = [self indexOfFilterString:eachKey];
        if (index == NSNotFound) {
            if ([eachKey isEqual:@"searchText"]) {
                [Prefer shared].searchText = result[eachKey];
            }
            else if ([eachKey isEqual:@"rating"]) {
                [Prefer shared].rating = result[eachKey];;
            }
        }
        else {
            [[Prefer shared].flags replaceObjectAtIndex:index withObject:result[eachKey]];
        }
    }
    [[Prefer shared] sync];
    [self.delegate onSearchFilterDone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark * misc

//找看有沒有這個 filter string, 有的話就要用 index 寫回 filtersFlag, 沒有的就直接用 key 去寫值
- (NSUInteger)indexOfFilterString:(NSString *)filterString {
    for (FilterItem *item in [Filter shared].items) {
        if ([filterString isEqualToString:item.title]) {
            return [[Filter shared].items indexOfObject:item];
        }
    }
    return NSNotFound;
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
