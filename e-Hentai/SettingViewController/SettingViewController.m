//
//  SettingViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/3.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#pragma mark - ibaction

- (IBAction)cleanCacheAction:(id)sender {
    [[FilesManager cacheFolder] rd:@"Hentai"];
    [HentaiCacheLibrary removeAllCacheInfo];
    [self cacheFolderSize];
}

- (IBAction)cleanDocumentAction:(id)sender {
    NSArray *folders = [[[FilesManager documentFolder] fcd:@"Hentai"] listFolders];
    
    //檢查每一個資料夾名稱是否存在於已下載列表, 或是 download queue 裡面
    for (NSString *eachFolderName in folders) {
        BOOL isExist = NO;
        
        //檢查有沒有在列表內
        for (int i=0; i<[HentaiSaveLibrary count]; i++) {
            NSDictionary *eachSaveHentaiInfo = [HentaiSaveLibrary saveInfoAtIndex:i];
            NSString *hentaiKey = [eachSaveHentaiInfo[@"hentaiInfo"] hentai_hentaiKey];
            
            if ([hentaiKey rangeOfString:eachFolderName].location != NSNotFound) {
                isExist = YES;
                break;
            }
        }
        
        //檢查有沒有在下載列表內
        if (!isExist) {
            isExist |= [HentaiDownloadCenter isActiveFolder:eachFolderName];
        }
        
        //如果都沒有的話就要殺掉他
        if (!isExist) {
            [[[FilesManager documentFolder] fcd:@"Hentai"] rd:eachFolderName];
        }
    }
    [self documentFolderSize];
}

#pragma mark - private

//code form FLEX
- (void)cacheFolderSize {
    __weak SettingViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:[[[FilesManager cacheFolder] fcd:@"Hentai"] currentPath] error:NULL];
        uint64_t totalSize = [attributes fileSize];
        
        for (NSString *fileName in[fileManager enumeratorAtPath:[[[FilesManager cacheFolder] fcd:@"Hentai"] currentPath]]) {
            attributes = [fileManager attributesOfItemAtPath:[[[[FilesManager cacheFolder] fcd:@"Hentai"] currentPath] stringByAppendingPathComponent:fileName] error:NULL];
            totalSize += [attributes fileSize];
            
            if (!weakSelf) {
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong SettingViewController *strongSelf = weakSelf;
            NSString *sizeString = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
            strongSelf.cacheSizeLabel.text = [NSString stringWithFormat:@"占用容量: %@", sizeString];
        });
    });
}

//code form FLEX
- (void)documentFolderSize {
    __weak SettingViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:[[[FilesManager documentFolder] fcd:@"Hentai"] currentPath] error:NULL];
        uint64_t totalSize = [attributes fileSize];
        
        for (NSString *fileName in[fileManager enumeratorAtPath:[[[FilesManager documentFolder] fcd:@"Hentai"] currentPath]]) {
            attributes = [fileManager attributesOfItemAtPath:[[[[FilesManager documentFolder] fcd:@"Hentai"] currentPath] stringByAppendingPathComponent:fileName] error:NULL];
            totalSize += [attributes fileSize];
            
            if (!weakSelf) {
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong SettingViewController *strongSelf = weakSelf;
            NSString *sizeString = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
            strongSelf.downloadedSizeLabel.text = [NSString stringWithFormat:@"下載容量: %@", sizeString];
        });
    });
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"設定";
    [self cacheFolderSize];
    [self documentFolderSize];
}

@end
