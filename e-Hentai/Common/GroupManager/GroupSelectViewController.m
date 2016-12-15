//
//  GroupSelectViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "GroupSelectViewController.h"

@interface GroupSelectViewController ()

@property (nonatomic, strong) NSMutableArray *groupTitles;

@end

@implementation GroupSelectViewController

- (void)setOriginGroup:(NSString *)originGroup {
    _originGroup = originGroup;
    NSInteger selectedIndex = -1;
    for (NSString *eachTitle in self.groupTitles) {
        if ([eachTitle isEqualToString:originGroup]) {
            selectedIndex = [self.groupTitles indexOfObject:eachTitle];
            break;
        }
    }
    QSection *existingGroupSection = [self.root sectionWithKey:@"existingGroupSection"];
    QRadioElement *existingGroupElement = existingGroupSection.elements[0];
    existingGroupElement.selected = selectedIndex;
    [self.quickDialogTableView reloadData];
}

#pragma mark - private

#pragma mark * init

- (QRootElement *)rootMaker {
    //基本樣貌設定
    QRootElement *root = [QRootElement new];
    root.grouped = YES;
    root.title = @"選擇分類";
    root.controllerName = @"GroupSelectViewController";
    
    //建立分類 section
    QSection *createGroupSection = [[QSection alloc] initWithTitle:@"建立分類"];
    QEntryElement *createGroupElement = [[QEntryElement alloc] initWithTitle:@"建立一個新的分類" Value:@"" Placeholder:@"留白則為不分類"];
    createGroupElement.key = @"createGroup";
    [createGroupSection addElement:createGroupElement];
    [root addSection:createGroupSection];
    
    NSArray *groups = [HentaiSaveLibrary groups];
    
    //如果有舊有分類才秀這個部分
    if ([groups count]) {
        self.groupTitles = [NSMutableArray array];
        for (NSDictionary *eachGroup in groups) {
            [self.groupTitles addObject:eachGroup[@"title"]];
        }
        QSection *existingGroupSection = [[QSection alloc] initWithTitle:@"舊有分類"];
        existingGroupSection.key = @"existingGroupSection";
        QRadioElement *existingGroupElement = [[QRadioElement alloc] initWithItems:self.groupTitles selected:-1 title:@"從舊有分類選擇"];
        existingGroupElement.key = @"existingGroup";
        [existingGroupSection addElement:existingGroupElement];
        [root addSection:existingGroupSection];
    }
    
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
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion: ^{
        @strongify(self);
        if (self) {
            self.completion(nil);
        }
    }];
}

- (void)doneAction {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self.root fetchValueIntoObject:result];
    
    NSString *createGroupString = [result[@"createGroup"] hentai_withoutSpace];
    
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion: ^{
        @strongify(self);
        
        if (self) {
            //沒有舊分類的時候
            if ([result count] == 1) {
                self.completion(createGroupString);
            }
            else {
                NSNumber *indexOfExistingGroup = result[@"existingGroup"];
                if ([indexOfExistingGroup integerValue] == -1) {
                    self.completion(createGroupString);
                }
                else {
                    NSString *existingGroupString = [self.groupTitles[[indexOfExistingGroup integerValue]] hentai_withoutSpace];
                    
                    if (![createGroupString isEqualToString:@""]) {
                        self.completion(createGroupString);
                    }
                    else {
                        self.completion(existingGroupString);
                    }
                }
            }
        }
    }];
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
