//
//  HentaiDownloadCenter.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/9.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HentaiImagesManager.h"

@interface HentaiDownloadCenter : NSObject

+ (HentaiImagesManager *)manager:(HentaiInfo *)info andParser:(Class)parser;
+ (void)bye:(HentaiInfo *)info;
+ (CGFloat)downloadProgress:(HentaiInfo *)info;

@end
