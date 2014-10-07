//
//  UITableViewCell+Hentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/7.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "UITableViewCell+Hentai.h"

@implementation UITableViewCell (Hentai)

- (NSIndexPath *)hentai_indexPath {
    UIView *findView = self.superview;
    while (![findView isKindOfClass:[UITableView class]]) {
        findView = findView.superview;
    }
    UITableView *table = (UITableView *)findView;
    return [table indexPathForCell:self];
}

@end
