//
//  HentaiDownloadOperation.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/5.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HentaiDownloadOperationDelegate;

@interface HentaiDownloadOperation : NSOperation

@property (nonatomic, weak) id <HentaiDownloadOperationDelegate> delegate;
@property (nonatomic, strong) NSString *downloadURLString;
@property (nonatomic, strong) NSString *hentaiKey;

@end

@protocol HentaiDownloadOperationDelegate <NSObject>

@required
- (void)downloadResult:(NSString *)urlString heightOfSize:(CGFloat)height isSuccess:(BOOL)isSuccess;

@end
