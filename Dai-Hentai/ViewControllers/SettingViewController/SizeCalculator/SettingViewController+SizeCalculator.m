//
//  SettingViewController+SizeCalculator.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/11.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SettingViewController+SizeCalculator.h"
#import "DBGallery.h"
#import "FilesManager.h"

@implementation SettingViewController (SizeCalculator)

#pragma mark - Private Instance Method

- (void)sizeCalculator {
    if (![self.sizeLock tryLock]) {
        return;
    }
    
    self.historySizeLabel.text = @"計算中...";
    self.downloadSizeLabel.text = @"計算中...";
    NSArray<HentaiInfo *> *hentaiInfos = [DBGallery all];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attributes = nil;
        unsigned long long totalFileSize = 0;
        unsigned long long historySize = 0;
        NSInteger historyCount = 0;
        unsigned long long downloadSize = 0;
        NSInteger downloadCount = 0;
        
        for (HentaiInfo *info in hentaiInfos) {
            NSString *path = [[FilesManager documentFolder] cd:[info folder]].currentPath;
            totalFileSize = 0;
            for (NSString *fileName in [fileManager enumeratorAtPath:path]) {
                attributes = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:NULL];
                totalFileSize += [attributes fileSize];
            }
            
            if (info.downloaded.integerValue) {
                downloadSize += totalFileSize;
                downloadCount++;
            }
            else {
                historySize += totalFileSize;
                historyCount++;
            }
        }
        
        NSString *historySizeString = [NSByteCountFormatter stringFromByteCount:historySize countStyle:NSByteCountFormatterCountStyleFile];
        NSString *downloadSizeString = [NSByteCountFormatter stringFromByteCount:downloadSize countStyle:NSByteCountFormatterCountStyleFile];
        
        @strongify(self);
        if (!self) {
            return;
        }
        
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!self) {
                return;
            }
            self.historySizeLabel.text = [NSString stringWithFormat:@"%@ (%@)", historySizeString, @(historyCount)];
            self.downloadSizeLabel.text = [NSString stringWithFormat:@"%@ (%@)", downloadSizeString, @(downloadCount)];
            [self.sizeLock unlock];
        });
    });
}


@end
