//
//  SettingViewController.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/31.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SettingViewController.h"
#import "EXTScope.h"
#import "DBGallery.h"
#import "FilesManager.h"
#import "UIAlertController+Block.h"
#import "AuthHelper.h"

@interface SettingViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *historySizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *scrollDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lockThisAppLabel;

@property (nonatomic, strong) NSLock *sizeLock;

@end

@implementation SettingViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"ScrollDirectionCell"]) {
        [self onScrollDirectionPress];
    }
    else if ([cell.reuseIdentifier isEqualToString:@"LockThisAppCell"]) {
        [self onLockThisAppPress];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

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
            NSString *folder = info.title_jpn.length ? info.title_jpn : info.title;
            folder = [[folder componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
            NSString *path = [[FilesManager documentFolder] cd:folder].currentPath;
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

- (void)onScrollDirectionPress {
    if (self.info.scrollDirection.integerValue == UICollectionViewScrollDirectionVertical) {
        self.info.scrollDirection = @(UICollectionViewScrollDirectionHorizontal);
    }
    else {
        self.info.scrollDirection = @(UICollectionViewScrollDirectionVertical);
    }
    [self displayCurrentScrollDirectionText];
}

- (void)displayCurrentScrollDirectionText {
    if (self.info.scrollDirection.integerValue == UICollectionViewScrollDirectionVertical) {
        self.scrollDirectionLabel.text = @"上下捲動";
    }
    else {
        self.scrollDirectionLabel.text = @"左右捲動";
    }
}

- (void)onLockThisAppPress {
    if (self.info.isLockThisApp.boolValue) {
        @weakify(self);
        [AuthHelper checkFor:@"驗證身份以解除鎖定" completion: ^(BOOL pass) {
            @strongify(self);
            
            if (pass) {
                self.info.isLockThisApp = @(NO);
                [self displayLockThisAppText];
            }
            else {
                [UIAlertController showAlertTitle:@"解除失敗" message:nil defaultOptions:nil cancelOption:@"QwQ 好8" handler:nil];
            }
        }];
        return;
    }
    
    // 無上鎖時, 跟用戶確認要上鎖這件事
    @weakify(self);
    [UIAlertController showAlertTitle:@"確定要上鎖嗎?" message:@"未來只可以透過指紋或是臉來解鎖, 密碼無法!" defaultOptions:@[ @"OK, 鎖8" ] cancelOption:@"O口O 真假, 我考慮一下" handler: ^(NSInteger optionIndex) {
        if (!optionIndex) {
            return;
        }
        
        @strongify(self);
        if ([AuthHelper canLock]) {
            self.info.isLockThisApp = @(YES);
            [self displayLockThisAppText];
        }
    }];
}

- (void)displayLockThisAppText {
    if (self.info.isLockThisApp.boolValue) {
        self.lockThisAppLabel.text = @"目前是上鎖狀態";
    }
    else {
        self.lockThisAppLabel.text = @"目前是沒有上鎖狀態";
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.sizeLock = [NSLock new];
    self.info = [DBUserPreference info];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sizeCalculator];
    [self displayCurrentScrollDirectionText];
    [self displayLockThisAppText];
}

@end
