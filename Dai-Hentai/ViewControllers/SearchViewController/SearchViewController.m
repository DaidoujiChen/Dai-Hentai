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
#import "CategoryItem.h"

@implementation SearchViewController

#pragma mark - Private Class Method

+ (NSMutableArray<CategoryItem *> *)categories {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray<CategoryItem *> *categories = [NSMutableArray array];
        [categories addObject:[CategoryItem itemWith:@"Keyword" getter:@"keyword"]];
        [categories addObject:[CategoryItem itemWith:@"Rating" getter:@"rating"]];
        [categories addObject:[CategoryItem itemWith:@"Doujinshi" getter:@"doujinshi"]];
        [categories addObject:[CategoryItem itemWith:@"Manga" getter:@"manga"]];
        [categories addObject:[CategoryItem itemWith:@"Artist CG" getter:@"artistcg"]];
        [categories addObject:[CategoryItem itemWith:@"Game CG" getter:@"gamecg"]];
        [categories addObject:[CategoryItem itemWith:@"Western" getter:@"western"]];
        [categories addObject:[CategoryItem itemWith:@"Non-H" getter:@"non_h"]];
        [categories addObject:[CategoryItem itemWith:@"Image Set" getter:@"imageset"]];
        [categories addObject:[CategoryItem itemWith:@"Cosplay" getter:@"cosplay"]];
        [categories addObject:[CategoryItem itemWith:@"Asian Porn" getter:@"asianporn"]];
        [categories addObject:[CategoryItem itemWith:@"Misc" getter:@"misc"]];
        objc_setAssociatedObject(self, _cmd, categories, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SearchViewController categories].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchBaseCell *cell;
    CategoryItem *category = [SearchViewController categories][indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchKeywordCell" forIndexPath:indexPath];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchRatingCell" forIndexPath:indexPath];
            break;
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCategoryCell" forIndexPath:indexPath];
            cell.textLabel.text = category.title;
            break;
    }
    
    __weak SearchViewController *weakSelf = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [cell setSeachValue:[self.info performSelector:category.getterSEL] onChange: ^(id newValue) {
        if (weakSelf) {
            __strong SearchViewController *strongSelf = weakSelf;
            [strongSelf.info performSelector:category.setterSEL withObject:newValue];
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

@end
