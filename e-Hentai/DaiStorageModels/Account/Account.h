//
//  Account.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/4/24.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiStorage.h"

@interface Account : DaiStorage

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (void)sync;

@end
