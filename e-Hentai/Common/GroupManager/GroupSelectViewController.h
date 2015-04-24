//
//  GroupSelectViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/19.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "QuickDialogController.h"

@interface GroupSelectViewController : QuickDialogController

@property (nonatomic, copy) void (^completion)(NSString *selectedGroup);
@property (nonatomic, strong) NSString *originGroup;

@end
