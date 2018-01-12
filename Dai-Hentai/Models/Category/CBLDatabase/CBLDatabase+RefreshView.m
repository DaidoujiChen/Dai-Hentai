//
//  CBLDatabase+RefreshView.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/15.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "CBLDatabase+RefreshView.h"

@implementation CBLDatabase (RefreshView)

- (CBLView *)refreshViewNamed:(NSString *)name {
    [[self viewNamed:name] deleteView];
    return [self viewNamed:name];
}

@end
