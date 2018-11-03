//
//  HentaiImagesManager.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/9.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "HentaiImagesManager.h"
#import <objc/runtime.h>
#import "NSTimer+Block.h"
#import "DBGallery.h"

@interface HentaiImagesManager ()

@property (nonatomic, strong) HentaiInfo *info;
@property (nonatomic, strong) Class parser;
@property (nonatomic, assign) NSInteger totalPageIndex;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, strong) NSLock *pageLocker;
@property (nonatomic, strong) NSMutableArray<NSString *> *imagePages;
@property (nonatomic, strong) NSMutableArray<NSString *> *loadingImagePages;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSNumber *> *> *heights;
@property (nonatomic, strong) FMStream *storage;
@property (nonatomic, strong) NSNumber *isExist;
@property (nonatomic, assign) BOOL aliveForDownload;
@property (nonatomic, readonly) BOOL isDownloadFinish;

@end

@implementation HentaiImagesManager

#pragma mark - Class Method

+ (UIImage *)placeholder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [UIImage imageNamed:@"placeholder"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Private Instance Method

// 處理完圖片可以作為顯示使用
- (void)displayImage:(NSString *)imagePage data:(NSData *)data {
    NSString *filename = imagePage.lastPathComponent;
    NSInteger pageIndex = [[filename componentsSeparatedByString:@"-"][1] integerValue] - 1;
    
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        imageWidth = image.size.width;
        imageHeight = image.size.height;
    }
    
    __weak HentaiImagesManager *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf) {
            return;
        }
        
        __strong HentaiImagesManager *strongSelf = weakSelf;
        strongSelf.heights[@(pageIndex)] = @{ @"width": @(imageWidth), @"height": @(imageHeight) };
        [strongSelf.delegate imageHeightChangedAtPageIndex:pageIndex];
        
        if (strongSelf.aliveForDownload) {
            NSInteger totalImages = strongSelf.heights.count;
            if (totalImages + 20 >= strongSelf.imagePages.count) {
                [strongSelf fetch:nil];
            }
            
            if (strongSelf.isDownloadFinish) {
                strongSelf.aliveForDownload = NO;
                [strongSelf.internalDelegate downloadFinish:strongSelf.info];
            }
        }
    });
}

// 當圖片準備好時
- (void)onImageReady:(NSString *)imagePage data:(NSData *)data {
    if ([NSThread isMainThread]) {
        __weak HentaiImagesManager *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!weakSelf) {
                return;
            }
            
            __strong HentaiImagesManager *strongSelf = weakSelf;
            [strongSelf displayImage:imagePage data:data];
        });
    }
    else {
        [self displayImage:imagePage data:data];
    }
}

// 從 https://e-hentai.org/s/107f1048f2/1030726-1 頁面中
// 取得真實的圖片連結 ex: http://114.33.249.224:18053/h/e6d61323621dc2c578266d3192578edb66ad1517-99131-1280-845-jpg/keystamp=1487226600-fd28acd1f7;fileindex=50314533;xres=1280/60785277_p0.jpg
- (void)downloadImage:(NSString *)imagePage {
    if ([self.loadingImagePages containsObject:imagePage]) {
        return;
    }
    
    [self.loadingImagePages addObject:imagePage];
    __weak HentaiImagesManager *weakSelf = self;
    [self.parser requestImageURL:imagePage completion: ^(HentaiParserStatus status, NSString *imageURL) {
        if (!weakSelf) {
            return;
        }
        
        if (status == HentaiParserStatusSuccess) {
            // TODO: 下載的部份可能要用 nsoperation queue 來控量比較好?
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!weakSelf) {
                    return;
                }
                __strong HentaiImagesManager *strongSelf = weakSelf;
                [strongSelf.loadingImagePages removeObject:imagePage];
                
                if (error || !data) {
                    NSLog(@"===== Load imagePage Fail : %@, %@", imagePage, imageURL);
                }
                
                NSString *filename = imagePage.lastPathComponent;
                if (data) {
                    [strongSelf.storage write:data filename:filename];
                }
                [strongSelf onImageReady:imagePage data:data];
            }];
            [task resume];
            [NSTimer scheduledTimerWithTimeInterval:15.0f repeats:NO usingBlock: ^{
                if (task.state != NSURLSessionTaskStateCompleted) {
                    [task cancel];
                }
            }];
        }
        else {
            NSLog(@"===== requestImageURLWithURLString fail");
            [weakSelf.loadingImagePages removeObject:imagePage];
        }
    }];
}

- (BOOL)isDownloadFinish {
    // 當第一次進入時 heights / imagePages 會是 0
    // 直接被判斷為已完成下載, 所以當 imagePages 為 0 時, 應該回還沒有下載完成
    if (self.imagePages.count == 0) {
        return NO;
    }
    return self.heights.count == self.imagePages.count;
}

#pragma mark - Instance Method

- (void)fetch:(void (^)(BOOL isExist))result {
    if (self.isExist && result) {
        result(self.isExist.boolValue);
    }
    
    if (![self.pageLocker tryLock]) {
        return;
    }
    
    if (self.currentPageIndex > self.totalPageIndex) {
        return;
    }
    
    __weak HentaiImagesManager *weakSelf = self;
    [self.parser requestImagePagesBy:self.info atIndex:self.currentPageIndex completion: ^(HentaiParserStatus status, NSInteger nextIndex, NSArray<NSString *> *imagePages) {
        if (!weakSelf) {
            return;
        }
        __strong HentaiImagesManager *strongSelf = weakSelf;
        
        // 提早解鎖, 避免卡住的現象
        [strongSelf.pageLocker unlock];
        
        if (status == HentaiParserStatusSuccess) {
            if (strongSelf.currentPageIndex == 0) {
                strongSelf.isExist = @(imagePages.count != 0);
                if (result) {
                    result(strongSelf.isExist.boolValue);
                }
            }
            strongSelf.currentPageIndex = nextIndex;
            [strongSelf.imagePages addObjectsFromArray:imagePages];
            
            for (NSString *imagePage in imagePages) {
                NSString *filename = imagePage.lastPathComponent;
                NSInteger currentPage = [[filename componentsSeparatedByString:@"-"][1] integerValue];
                NSData *existData = [strongSelf.storage read:filename];
                if (existData) {
                    [strongSelf onImageReady:imagePage data:existData];
                }
                // 當看過的頁面到比較後面, 可是這前面有沒有讀取完的圖片, 會導致在跳頁的時候發生 crash 的問題
                // 所以這邊我們先用一張空圖來避免掉這個問題, 並且在這個同時把他放到下載的 queue 裡面
                else if (currentPage <= [strongSelf.info latestPage]) {
                    [strongSelf onImageReady:imagePage data:nil];
                    [strongSelf downloadImage:imagePage];
                }
                else {
                    [strongSelf downloadImage:imagePage];
                }
            }
        }
        else {
            NSLog(@"===== requestImagePagesBy fail");
        }
    }];
}

// 補齊下載失敗的圖片
- (void)downloadImageAt:(NSInteger)index {
    [self downloadImage:self.imagePages[index]];
}

// 讀取圖片完後送回
- (void)loadImageAt:(NSInteger)index completion:(void (^)(UIImage *image))completion {
    __weak HentaiImagesManager *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf) {
            return;
        }
        
        __strong HentaiImagesManager *strongSelf = weakSelf;
        NSString *filename = strongSelf.imagePages[index].lastPathComponent;
        UIImage *image = [UIImage imageWithData:[strongSelf.storage read:filename]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image);
            }
        });
    });
}

- (BOOL)isReadyAt:(NSInteger)index {
    return !(self.heights[@(index)][@"width"].floatValue == 0 && self.heights[@(index)][@"height"].floatValue == 0);
}

- (void)giveMeAll {
    if (!self.isDownloadFinish) {
        self.aliveForDownload = YES;
    }
}

- (void)stop {
    self.aliveForDownload = NO;
}

- (CGFloat)downloadProgress {
    return ((CGFloat)self.heights.count) / self.info.filecount.floatValue;
}

#pragma mark - Life Cycle

- (instancetype)initWith:(HentaiInfo *)info andParser:(Class)parser {
    self = [super init];
    if (self) {
        self.info = info;
        self.parser = parser;
        self.currentPageIndex = 0;
        self.totalPageIndex = floor(info.filecount.floatValue / 40.0f);
        self.pageLocker = [NSLock new];
        self.imagePages = [NSMutableArray array];
        self.loadingImagePages = [NSMutableArray array];
        self.heights = [NSMutableDictionary dictionary];
        self.storage = [[FilesManager documentFolder] fcd:[info folder]];
        self.aliveForDownload = NO;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"===== HentaiImagesManager dealloc");
}

@end
