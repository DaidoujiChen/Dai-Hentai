//
//  RelatedViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/4/3.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "RelatedViewController.h"
#import "SearchCategoryCell.h"
#import "Translator.h"

typedef enum {
    SectionTypeEng = 0,
    SectionTypeJpn,
    SectionTypeTag
} SectionType;

@interface RelatedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSNumber *> *sections;
@property (nonatomic, strong) NSArray<NSString *> *engWords;
@property (nonatomic, strong) NSArray<NSString *> *jpnWords;

@end

@implementation RelatedViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.sections[section].integerValue) {
        case SectionTypeEng:
            return self.engWords.count;
            
        case SectionTypeJpn:
            return self.jpnWords.count;
            
        case SectionTypeTag:
            return self.info.tags.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelatedCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SearchCategoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *word;
    switch (self.sections[indexPath.section].integerValue) {
        case SectionTypeEng:
            word = self.engWords[indexPath.row];
            break;
            
        case SectionTypeJpn:
            word = self.jpnWords[indexPath.row];
            break;
            
        case SectionTypeTag:
            word = self.info.tags[indexPath.row];
            break;
    }
    BOOL isExist = [self.selectedWords containsObject:word];
    __weak RelatedViewController *weakSelf = self;
    [cell setSeachValue:@(isExist) onChange: ^(NSNumber *newValue) {
        if (weakSelf) {
            __strong RelatedViewController *strongSelf = weakSelf;
            if (newValue.boolValue) {
                [strongSelf.selectedWords addObject:word];
            }
            else {
                [strongSelf.selectedWords removeObject:word];
            }
        }
    }];
    NSString *translator = [Translator from:word];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", word, translator];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (self.sections[section].integerValue) {
        case SectionTypeEng:
            return @"英文名稱切碎";
            
        case SectionTypeJpn:
            return @"日文名稱切碎";
            
        case SectionTypeTag:
            return @"Tags";
            
        default:
            return @"";
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Instance Method

- (void)initValues {
    NSMutableArray *sections = [NSMutableArray array];
    NSArray *words = [self.info engTitleSplit];
    if (words.count) {
        self.engWords = words;
        [sections addObject:@(SectionTypeEng)];
    }
    
    words = [self.info jpnTitleSplit];
    if (words.count) {
        self.jpnWords = words;
        [sections addObject:@(SectionTypeJpn)];
    }
    
    [sections addObject:@(SectionTypeTag)];
    self.sections = sections;
    
    self.selectedWords = [NSMutableArray array];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
}

@end
