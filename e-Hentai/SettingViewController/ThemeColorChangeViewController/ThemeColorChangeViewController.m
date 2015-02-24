//
//  ThemeColorChangeViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/7.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "ThemeColorChangeViewController.h"

#import <objc/runtime.h>

@interface ThemeColorChangeViewController ()

@property (nonatomic, strong) NSString *currentColorString;
@property (nonatomic, strong) NSMutableArray *availableColors;

@end

@implementation ThemeColorChangeViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableColors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //建立 cell
    MenuDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AvailableColorCell" forIndexPath:indexPath];
    cell.textLabel.text = self.availableColors[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.availableColors[indexPath.row] isEqualToString:self.currentColorString]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentColorString = self.availableColors[indexPath.row];
    [tableView reloadData];
    [self changeToColor:self.currentColorString];
}

#pragma mark - private

#pragma mark * init

- (void)setupInitValues {
    self.currentColorString = [HentaiSettingManager temporarySettings][@"themeColor"];
    [self foundFlatColors];
}

//找出所有 flat 色
- (void)foundFlatColors {
    self.availableColors = [NSMutableArray array];
    unsigned int methodCount;
    Class metaClass = objc_getMetaClass(class_getName([UIColor class]));
    Method *methodList = class_copyMethodList(metaClass, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        NSString *methodName = NSStringFromSelector(method_getName(methodList[i]));
        if ([methodName rangeOfString:@"flat"].location != NSNotFound && ![methodName isEqualToString:@"flatColors"]) {
            [self.availableColors addObject:methodName];
        }
    }
}

//設定 filter table
- (void)setupAvailableColorsTableView {
    UITableView *availableColorsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    availableColorsTableView.delegate = self;
    availableColorsTableView.dataSource = self;
    availableColorsTableView.backgroundColor = [UIColor clearColor];
    [availableColorsTableView registerClass:[MenuDefaultCell class] forCellReuseIdentifier:@"AvailableColorCell"];
    [self.view addSubview:availableColorsTableView];
}

//設置按鈕
- (void)setupItemsOnNavigation {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitChange)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark * button actions

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)submitChange {
    [HentaiSettingManager temporarySettings][@"themeColor"] = self.currentColorString;
    [[self portal:PortalChangeThemeColor] send:DaiPortalPackageItem(self.currentColorString)];
    [self.delegate themeColorDidChange];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupItemsOnNavigation];
    [self setupAvailableColorsTableView];
}

@end
