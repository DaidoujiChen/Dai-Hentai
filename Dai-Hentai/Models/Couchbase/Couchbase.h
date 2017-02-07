//
//  Couchbase.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/10.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface Couchbase : NSObject

+ (void)tryCreate;
+ (void)tryQuery;

@end
