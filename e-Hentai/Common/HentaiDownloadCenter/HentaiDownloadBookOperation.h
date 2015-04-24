//
//  HentaiDownloadBookOperation.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/11.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HentaiDownloadImageOperation.h"

typedef enum {
    HentaiDownloadBookOperationStatusWaiting,
    HentaiDownloadBookOperationStatusDownloading,
    HentaiDownloadBookOperationStatusFinished
} HentaiDownloadBookOperationStatus;

@protocol HentaiDownloadBookOperationDelegate;

@interface HentaiDownloadBookOperation : NSOperation <HentaiDownloadImageOperationDelegate>

@property (nonatomic, weak) id <HentaiDownloadBookOperationDelegate> delegate;
@property (nonatomic, strong) NSDictionary *hentaiInfo;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, assign) HentaiDownloadBookOperationStatus status;
@property (nonatomic, readonly) NSInteger recvCount;
@property (nonatomic, readonly) NSInteger totalCount;

@end

@protocol HentaiDownloadBookOperationDelegate <NSObject>

@required
- (void)hentaiDownloadBookOperationChange:(HentaiDownloadBookOperation *)operation;

@end
