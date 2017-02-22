//
//  SearchViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/21.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Couchbase.h"

@interface SearchViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, strong) SearchInfo *info;

@end
