//
//  HentaiDownloadBookOperation.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/11.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HentaiDownloadImageOperation.h"

@interface HentaiDownloadBookOperation : NSOperation <HentaiDownloadImageOperationDelegate>

@property (nonatomic, strong) NSDictionary *bookInfo;

@end
