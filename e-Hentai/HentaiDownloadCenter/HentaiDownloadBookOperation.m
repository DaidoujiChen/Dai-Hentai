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
            
            NSUInteger removeIndex = NSNotFound;
            for (NSString *eachURLString in self.hentaiImageURLs) {
                if ([eachURLString isEqualToString:urlString]) {
                    removeIndex = [self.hentaiImageURLs indexOfObject:eachURLString];
                    break;
                }
            }
            
            if (removeIndex != NSNotFound) {
                [self.hentaiImageURLs removeObjectAtIndex:removeIndex];
            }
        }
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.delegate hentaiDownloadBookOperationChange:self];
    });
}

#pragma mark - operation status

- (void)hentaiStart {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.status = HentaiDownloadBookOperationStatusDownloading;
        [self.delegate hentaiDownloadBookOperationChange:self];
        self.isFinished = NO;
        self.isExecuting = YES;
    });
}

- (void)hentaiFinish {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.status = HentaiDownloadBookOperationStatusFinished;
        [self.delegate hentaiDownloadBookOperationChange:self];
        [self.hentaiQueue cancelAllOperations];
        self.isFinished = YES;
        self.isExecuting = NO;
    });
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
            if (status && ![self isCancelled] && [images count]) {
                [self.hentaiImageURLs addObjectsFromArray:images];
                [self preloadImages:images];
                [self waitingOnDownloadFinish];
            }
            else {
                [UIAlertView hentai_alertViewWithTitle:self.hentaiInfo[@"title"] message:@"被移除囉~所以無法下載~" cancelButtonTitle:@"好~ O3O"];
                [self hentaiFinish];
            }
        }];
    }
    else {
        if (![self isCancelled]) {
            NSDictionary *saveInfo = @{ @"hentaiKey":self.hentaiKey, @"images":self.hentaiImageURLs, @"hentaiResult":self.hentaiResults, @"hentaiInfo":self.hentaiInfo };
            
            if ([self verifySaveInfo:saveInfo]) {
                //如果 cache 有暫存就殺光光
                [[[FilesManager cacheFolder] fcd:@"Hentai"] rd:self.hentaiKey];
                [HentaiSaveLibrary addSaveInfo:saveInfo toGroup:self.group];
                [HentaiCacheLibrary removeCacheInfoForKey:self.hentaiKey];
                [[self portal:PortalHentaiDownloadSuccess] send:DaiPortalPackageItem(self.hentaiInfo[@"title"])];
            }
            else {
                [[self portal:PortalHentaiDownloadFail] send:DaiPortalPackageItem(self.hentaiInfo[@"title"])];
            }
            
            [self hentaiFinish];
        }
        else {
            [self hentaiFinish];
        }
    }
}

#pragma mark - private

- (BOOL)verifySaveInfo:(NSDictionary *)saveInfo {
    
    //檢查 hentaiKey
    if (!saveInfo[@"hentaiKey"]) {
        return NO;
    }
    
    //檢查 hentaiInfo
    NSDictionary *hentaiInfo = saveInfo[@"hentaiInfo"];
    if (!hentaiInfo[@"category"] || !hentaiInfo[@"filecount"] || !hentaiInfo[@"filesize"] || !hentaiInfo[@"posted"] || !hentaiInfo[@"rating"] || !hentaiInfo[@"thumb"] || !hentaiInfo[@"title"] || !hentaiInfo[@"title_jpn"] || !hentaiInfo[@"uploader"] || !hentaiInfo[@"url"]) {
        return NO;
    }
    
    //檢查 hentaiImageURLs
    NSArray *images = saveInfo[@"images"];
    for (id eachHentaiImageURL in images) {
        if (![eachHentaiImageURL isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    
    //檢查 hentaiResult
    NSDictionary *hentaiResult = saveInfo[@"hentaiResult"];
    for (NSString *eachKey in hentaiResult) {
        if (![hentaiResult[eachKey] isKindOfClass:[NSNumber class]]) {
            return NO;
        }
    }
    
    //數量應該是會一致的
    if ([images count] != [hentaiResult count]) {
        return NO;
    }
    
    return YES;
}

//建立一個新的 operation
- (void)createNewOperation:(NSString *)urlString {
    HentaiDownloadImageOperation *newOperation = [HentaiDownloadImageOperation new];
    newOperation.downloadURLString = urlString;
    newOperation.isCacheOperation = NO;
    newOperation.hentaiKey = self.hentaiKey;
    newOperation.delegate = self;
    newOperation.isHighResolution = [[HentaiSettingManager temporarySettings][@"highResolution"] boolValue];
    [self.hentaiQueue addOperation:newOperation];
}

@end
