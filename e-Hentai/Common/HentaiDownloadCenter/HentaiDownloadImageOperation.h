//
//  HentaiDownloadOperation.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HentaiDownloadImageOperationDelegate;

@interface HentaiDownloadImageOperation : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, weak) id <HentaiDownloadImageOperationDelegate> delegate;
@property (nonatomic, strong) NSString *downloadURLString;
@property (nonatomic, strong) NSString *hentaiKey;
@property (nonatomic, assign) BOOL isCacheOperation;
@property (nonatomic, assign) BOOL isHighResolution;

@end

@protocol HentaiDownloadImageOperationDelegate <NSObject>

@required
- (void)downloadResult:(NSString *)urlString heightOfSize:(CGFloat)height isSuccess:(BOOL)isSuccess;

@end
