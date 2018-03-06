//
//  SearchViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/21.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSearchSetting.h"

@interface SearchViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SearchInfo *info;

@end
