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

@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray<SearchItem *> *> *allItems;

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
            return @"從近期高頻關鍵字選取";
            
        case 2:
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
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchHintCell"];
            cell.textLabel.text = item.title;
            break;
            
        case 2:
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

- (NSArray<NSString *> *)recentKeywords {
    NSMutableDictionary<NSString *, NSNumber *> *recentKeywords = [NSMutableDictionary dictionary];
    
    // 找出最近期的 10 部作品
    NSArray<HentaiInfo *> *recentHentaiInfos = [DBGallery allFrom:0 length:10];
    for (HentaiInfo *info in recentHentaiInfos) {
        
        // 將每部作品的英文名 / 日文名 / tags 整理起來, 最後用 set 裝起來避免同一部作品重複太多同樣的字詞
        NSMutableArray<NSString *> *allWords = [NSMutableArray array];
        [allWords addObjectsFromArray:[info engTitleSplit]];
        [allWords addObjectsFromArray:[info jpnTitleSplit]];
        [allWords addObjectsFromArray:info.tags];
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

- (void)setupCategories {
    self.allItems = [NSMutableArray array];
    
    NSMutableArray<SearchItem *> *input = [NSMutableArray arrayWithObject:[SearchItem itemWith:@"Keyword" getter:@"keyword"]];
    [self.allItems addObject:input];
    
    NSMutableArray<SearchItem *> *hints = [NSMutableArray array];
    NSArray *recentHints = [self recentKeywords];
    for (NSInteger index = 0; index < MIN(recentHints.count, 5); index++) {
        [hints addObject:[SearchItem itemWith:recentHints[index] getter:@"hints"]];
    }
    [self.allItems addObject:hints];
    
    NSMutableArray<SearchItem *> *rate = [NSMutableArray arrayWithObject:[SearchItem itemWith:@"Rating" getter:@"rating"]];
    [self.allItems addObject:rate];
    
    NSMutableArray<SearchItem *> *categories = [NSMutableArray array];
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
