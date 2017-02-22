//
//  SearchBaseCell.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/23.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBaseCell : UITableViewCell

- (void)setSeachValue:(id)value onChange:(void (^)(id newValue))change;
- (void (^)(id newValue))onValueChange;

@end
