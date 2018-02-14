//
//  UserPreference.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/2/12.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "DaiStorage.h"

@interface UserPreference : DaiStorage

@property (nonatomic, strong) NSNumber *scrollDirection;
@property (nonatomic, strong) NSNumber *isLockThisApp;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end
