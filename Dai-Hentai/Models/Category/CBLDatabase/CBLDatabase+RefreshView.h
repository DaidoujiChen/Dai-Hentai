//
//  CBLDatabase+RefreshView.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/15.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLDatabase (RefreshView)

- (CBLView *)refreshViewNamed:(NSString *)name;

@end
