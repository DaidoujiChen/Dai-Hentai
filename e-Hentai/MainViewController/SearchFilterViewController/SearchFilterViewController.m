//
//  SearchFilterViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/29.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SearchFilterViewController.h"

@interface SearchFilterViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SearchFilterViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HentaiFilters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //取得一些要秀的資訊
    NSDictionary *filterInfo = HentaiFilters[indexPath.row];
    NSNumber *flag = HentaiPrefer[@"filtersFlag"][indexPath.row];
    
    //建立 cell
    MenuDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell" forIndexPath:indexPath];
    cell.textLabel.text = filterInfo[@"title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([flag boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取得資訊
    NSNumber *flag = HentaiPrefer[@"filtersFlag"][indexPath.row];
    
    //將 cell 的顯示狀態改變
    MenuDefaultCell *cell = (MenuDefaultCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([flag boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    HentaiPrefer[@"filtersFlag"][indexPath.row] = @(![flag boolValue]);
}

#pragma mark -  UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    [self alwaysEnableReturnKeyInSearchBar:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (self.delegate) {
        LWPSafe(
                HentaiPrefer[@"searchText"] = self.searchBar.text;
                LWPForceWrite();
        );
        [self.delegate onSearchFilterDone];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

#pragma mark -  UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - private

//讓 search bar 在沒有輸入字的情況下也可以按下搜尋按鈕
- (void)alwaysEnableReturnKeyInSearchBar:(UISearchBar *)searchBar {
    UITextField *searchField = nil;
    for (UIView *subView in searchBar.subviews) {
        for (UIView *childSubview in subView.subviews) {
            if ([childSubview isKindOfClass:[UITextField class]]) {
                searchField = (UITextField *)childSubview;
                break;
            }
        }
    }
    
    if (searchField) {
        searchField.enablesReturnKeyAutomatically = NO;
    }
}

- (void)setupItemsOnNavigation {
    //搜尋列
    self.searchBar = [UISearchBar new];
    self.searchBar.text = HentaiPrefer[@"searchText"];
    self.searchBar.placeholder = @"可以不填直接搜尋";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
}

#pragma mark - life cycle

- (id)init {
    self = [super initWithNibName:xibName bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupItemsOnNavigation];
    [self.filterTableView registerClass:[MenuDefaultCell class] forCellReuseIdentifier:@"FilterCell"];
}

@end
