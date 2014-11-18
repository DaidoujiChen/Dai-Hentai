//
//  HentaiDownloadBookOperation.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/9/11.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "HentaiDownloadBookOperation.h"

@interface HentaiDownloadBookOperation ()

@property (nonatomic, assign) NSUInteger hentaiIndex;
@property (nonatomic, strong) NSMutableArray *hentaiImageURLs;
@property (nonatomic, strong) NSMutableDictionary *retryMap;
@property (nonatomic, assign) NSUInteger failCount;
@property (nonatomic, strong) NSMutableDictionary *hentaiResults;
@property (nonatomic, readonly) NSString *hentaiKey;
@property (nonatomic, strong) NSOperationQueue *hentaiQueue;
@property (nonatomic, strong) NSString *maxHentaiCount;

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@end

@implementation HentaiDownloadBookOperation

@dynamic totalCount, recvCount;
@dynamic hentaiKey;

#pragma mark - dynamic

- (NSString *)hentaiKey {
    return [self.hentaiInfo hentai_hentaiKey];
}

- (NSInteger)totalCount {
    return [self.maxHentaiCount integerValue];
}

- (NSInteger)recvCount {
    return [self.hentaiResults count];
}

#pragma mark - life cycle

- (id)init {
    self = [super init];
    if (self) {
        //kvo status
        @weakify(self);
        [RACObserve(self, status) subscribeNext:^(NSNumber *status) {
            @strongify(self);
            [self.delegate hentaiDownloadBookOperationChange:self];
        }];
    }
    return self;
}

#pragma mark - Methods to Override

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    if ([self isCancelled]) {
        [self hentaiFinish];
        return;
    }
    
    [self hentaiStart];
    self.hentaiIndex = -1;
    self.hentaiImageURLs = [NSMutableArray array];
    self.retryMap = [NSMutableDictionary dictionary];
    self.failCount = 0;
    self.hentaiResults = [NSMutableDictionary dictionary];
    self.hentaiQueue = [NSOperationQueue new];
    [self.hentaiQueue setMaxConcurrentOperationCount:2];
    self.maxHentaiCount = self.hentaiInfo[@"filecount"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkEndOfFile];
    });
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return YES;
}

#pragma mark - HentaiDownloadImageOperationDelegate

- (void)downloadResult:(NSString *)urlString heightOfSize:(CGFloat)height isSuccess:(BOOL)isSuccess {
    if (isSuccess) {
        self.hentaiResults[[urlString hentai_lastTwoPathComponent]] = @(height);
    }
    else {
        NSNumber *retryCount = self.retryMap[urlString];
        if (retryCount) {
            retryCount = @([retryCount integerValue] + 1);
        }
        else {
            retryCount = @(1);
        }
        self.retryMap[urlString] = retryCount;
        
        if ([retryCount integerValue] <= 3) {
            [self createNewOperation:urlString];
            return;
        }
        else {
            self.failCount++;
            self.maxHentaiCount = [NSString stringWithFormat:@"%ld", [self.maxHentaiCount integerValue] - 1];
            [self.hentaiImageURLs removeObject:urlString];
        }
    }
    self.status = HentaiDownloadBookOperationStatusDownloading;
}

#pragma mark - operation status

- (void)hentaiStart {
    self.isFinished = NO;
    self.isExecuting = YES;
    self.status = HentaiDownloadBookOperationStatusDownloading;
}

- (void)hentaiFinish {
    [self.hentaiQueue cancelAllOperations];
    self.isFinished = YES;
    self.isExecuting = NO;
    self.status = HentaiDownloadBookOperationStatusFinished;
}

#pragma mark - download methods

//將要下載的圖片加到 queue 裡面
- (void)preloadImages:(NSArray *)images {
    for (NSString *eachImageString in images) {
        [self createNewOperation:eachImageString];
    }
}

//等待圖片下載完成
- (void)waitingOnDownloadFinish {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @strongify(self);
        [self.hentaiQueue waitUntilAllOperationsAreFinished];
        if (![self isCancelled]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkEndOfFile];
            });
        }
        else {
            [self hentaiFinish];
        }
    });
}

//檢查是不是還有圖片需要下載
- (void)checkEndOfFile {
    if ([self.hentaiImageURLs count] < [self.maxHentaiCount integerValue]) {
        self.hentaiIndex++;
        @weakify(self);
        [HentaiParser requestImagesAtURL:self.hentaiInfo[@"url"] atIndex:self.hentaiIndex completion: ^(HentaiParserStatus status, NSArray *images) {
            @strongify(self);
            if (![self isCancelled]) {
                switch (status) {
                    case HentaiParserStatusSuccess:
                        [self.hentaiImageURLs addObjectsFromArray:images];
                        [self preloadImages:images];
                        [self waitingOnDownloadFinish];
                        break;
                    case HentaiParserStatusNetworkFail:
                        [UIAlertView hentai_alertViewWithTitle:self.hentaiInfo[@"title"] message:@"網路失敗~所以無法下載~" cancelButtonTitle:@"好~ O3O"];
                        [self hentaiFinish];
                        break;
                    case HentaiParserStatusParseFail:
                        [UIAlertView hentai_alertViewWithTitle:self.hentaiInfo[@"title"] message:@"被移除囉~所以無法下載~" cancelButtonTitle:@"好~ O3O"];
                        [self hentaiFinish];
                        break;
                }
            }
        }];
    }
    else {
        if (![self isCancelled]) {
            NSDictionary *saveInfo = @{ @"hentaiKey":self.hentaiKey, @"images":self.hentaiImageURLs, @"hentaiResult":self.hentaiResults, @"hentaiInfo":self.hentaiInfo };
            
            //如果 cache 有暫存就殺光光
            [[[FilesManager cacheFolder] fcd:@"Hentai"] rd:self.hentaiKey];
            LWPSafe(
                    [HentaiSaveLibraryArray insertObject:saveInfo atIndex:0];
                    [HentaiCacheLibraryDictionary removeObjectForKey:self.hentaiKey];
                    LWPForceWrite();
            )
            [[NSNotificationCenter defaultCenter] postNotificationName:HentaiDownloadSuccessNotification object:self.hentaiInfo[@"title"]];
            [self hentaiFinish];
        }
        else {
            [self hentaiFinish];
        }
    }
}

#pragma mark - private

//建立一個新的 operation
- (void)createNewOperation:(NSString *)urlString {
    HentaiDownloadImageOperation *newOperation = [HentaiDownloadImageOperation new];
    newOperation.downloadURLString = urlString;
    newOperation.isCacheOperation = NO;
    newOperation.hentaiKey = self.hentaiKey;
    newOperation.delegate = self;
    [self.hentaiQueue addOperation:newOperation];
}

@end
