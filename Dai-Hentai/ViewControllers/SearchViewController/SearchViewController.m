//
//  SearchViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/21.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "SearchViewController.h"
#import <objc/runtime.h>
#import "SearchKeywordCell.h"
#import "SearchRatingCell.h"
#import "SearchCategoryCell.h"
#import "SearchItem.h"
#import "DBGallery.h"

typedef enum {
    RecentHintTypeTag,
    RecentHintTypeTitle
} RecentHintType;


@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray<SearchItem *> *> *allItems;
@property (nonatomic, strong) NSArray<HentaiInfo *> *recentHentaiInfos;

@end

@implementation SearchViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *rows = self.allItems[section];
    return rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"手動輸入關鍵字";
            
        case 1:
            return @"從近期標題選取";
            
        case 2:
            return @"從近期 Tag 選取";
            
        case 3:
            return @"評分要求";
            
        default:
            return @"作品類別";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchBaseCell *cell;
    NSMutableArray *rows = self.allItems[indexPath.section];
    SearchItem *item = rows[indexPath.row];
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchKeywordCell"];
            break;
            
        case 1:
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchHintCell"];
            cell.textLabel.text = item.title;
            break;
            
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchRatingCell"];
            break;
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCategoryCell"];
            cell.textLabel.text = item.title;
            break;
    }
    
    __weak SearchViewController *weakSelf = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [cell setSeachValue:[self.info performSelector:item.getterSEL] onChange: ^(id newValue) {
        if (weakSelf) {
            __strong SearchViewController *strongSelf = weakSelf;
            [strongSelf.info performSelector:item.setterSEL withObject:newValue];
        }
    }];
#pragma clang diagnostic pop
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIView *firstResponder = [self findFirstResponder:self.view];
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
}

#pragma mark - Private Instance Method

- (UIView *)findFirstResponder:(UIView *)view {
    if (view.isFirstResponder) {
        return view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView *foundView = [self findFirstResponder:subview];
        if (foundView) {
            return foundView;
        }
    }
    return nil;
}

- (NSArray<NSString *> *)recent:(RecentHintType)type {
    NSMutableDictionary<NSString *, NSNumber *> *recentKeywords = [NSMutableDictionary dictionary];
    
    // 利用近期 10 部作品來做統計
    for (HentaiInfo *info in self.recentHentaiInfos) {
        
        NSMutableArray<NSString *> *allWords = [NSMutableArray array];
        switch (type) {
            // tag 的部分
            case RecentHintTypeTag:
                [allWords addObjectsFromArray:info.tags];
                break;
            
            // 標題的部分, 如果有日文則用日文的, 反之才用一般的
            case RecentHintTypeTitle:
            {
                NSArray<NSString *> *titles = [info jpnTitleSplit];
                if (titles.count) {
                    [allWords addObjectsFromArray:titles];
                }
                else {
                    [allWords addObjectsFromArray:[info engTitleSplit]];
                }
                break;
            }
        }
        NSSet<NSString *> *recentSet = [NSSet setWithArray:[allWords valueForKey:@"lowercaseString"]];
        
        // 將計算完的字詞紀錄出現頻率
        NSArray<NSString *> *keywords = recentSet.allObjects;
        for (NSString *keyword in keywords) {
            if (recentKeywords[keyword]) {
                recentKeywords[keyword] = @(recentKeywords[keyword].integerValue + 1);
                continue;
            }
            recentKeywords[keyword] = @(1);
        }
    }
    
    // 依照出現的次數多 -> 寡排序
    return [recentKeywords keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj2 compare:obj1];
    }];
}

- (NSArray<NSString *> *)recentTags {
    return [self recent:RecentHintTypeTag];
}

- (NSArray<NSString *> *)recentTitles {
    return [self recent:RecentHintTypeTitle];
}

- (void)setupCategories {
    self.recentHentaiInfos = [DBGallery allFrom:0 length:10];
    self.allItems = [NSMutableArray array];
    
    NSMutableArray<SearchItem *> *input = [NSMutableArray arrayWithObject:[SearchItem itemWith:@"Keyword" getter:@"keyword"]];
    [self.allItems addObject:input];
    
    NSMutableArray<SearchItem *> *titleHints = [NSMutableArray array];
    NSArray *recentTitles = [self recentTitles];
    for (NSInteger index = 0; index < MIN(recentTitles.count, 5); index++) {
        [titleHints addObject:[SearchItem itemWith:recentTitles[index] getter:@"hints"]];
    }
    [self.allItems addObject:titleHints];
    
    NSMutableArray<SearchItem *> *tagHints = [NSMutableArray array];
    NSArray *recentTags = [self recentTags];
    for (NSInteger index = 0; index < MIN(recentTags.count, 5); index++) {
        [tagHints addObject:[SearchItem itemWith:recentTags[index] getter:@"hints"]];
    }
    [self.allItems addObject:tagHints];
    
    NSMutableArray<SearchItem *> *rate = [NSMutableArray arrayWithObject:[SearchItem itemWith:@"Rating" getter:@"rating"]];
    [self.allItems addObject:rate];
    
    NSMutableArray<SearchItem *> *categories = [NSMutableArray array];
    [categories addObject:[SearchItem itemWith:@"Chinese" getter:@"isChinese"]];
    [categories addObject:[SearchItem itemWith:@"Doujinshi" getter:@"doujinshi"]];
    [categories addObject:[SearchItem itemWith:@"Manga" getter:@"manga"]];
    [categories addObject:[SearchItem itemWith:@"Artist CG" getter:@"artistcg"]];
    [categories addObject:[SearchItem itemWith:@"Game CG" getter:@"gamecg"]];
    [categories addObject:[SearchItem itemWith:@"Western" getter:@"western"]];
    [categories addObject:[SearchItem itemWith:@"Non-H" getter:@"non_h"]];
    [categories addObject:[SearchItem itemWith:@"Image Set" getter:@"imageset"]];
    [categories addObject:[SearchItem itemWith:@"Cosplay" getter:@"cosplay"]];
    [categories addObject:[SearchItem itemWith:@"Asian Porn" getter:@"asianporn"]];
    [categories addObject:[SearchItem itemWith:@"Misc" getter:@"misc"]];
    [self.allItems addObject:categories];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCategories];
}

@end
