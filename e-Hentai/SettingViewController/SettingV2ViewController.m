//
//  SettingV2ViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2015/1/3.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "SettingV2ViewController.h"

@interface SettingV2ViewController ()

@end

@implementation SettingV2ViewController

#pragma mark - ThemeColorChangeViewControllerDelegate

- (void)themeColorDidChange {
    QSection *changeColorSection = [self.root sectionWithKey:@"changeColorSection"];
    QLabelElement *sizeElement = changeColorSection.elements[0];
    sizeElement.value = [Setting shared].themeColor;
    [self.quickDialogTableView reloadData];
}

#pragma mark - private

#pragma mark * init

- (void)setupItemsOnNavigation {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self.delegate action:@selector(sliderControl)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (QRootElement *)rootMaker {
    
    //基本樣貌設定
    QRootElement *root = [QRootElement new];
    root.grouped = YES;
    root.title = @"設定";
    root.controllerName = @"SettingV2ViewController";
    
    //設置一些簡易的開關們
    [root addSection:[self switchsSection]];
    
    //设置网络使用相关
    [root addSection:[self networkSection]];
    
    //更換顏色
    [root addSection:[self changeColorSection]];
    
    //快取
    [root addSection:[self cacheSizeSection]];
    
    //下載
    [root addSection:[self downloadSizeScetion]];
    return root;
}

#pragma mark * 功能區塊

- (QSection *)switchsSection {
    //開關們的 section
    QSection *switchsSection = [[QSection alloc] initWithTitle:@"開開關關"];
    
    //高清開關
    QBooleanElement *highResolutionElement = [[QBooleanElement alloc] initWithTitle:@"高清" BoolValue:[[Setting shared].highResolution boolValue]];
    highResolutionElement.controllerAction = @"highResolutionChange:";
    [switchsSection addElement:highResolutionElement];
    
    //顯示方式開關
    QBooleanElement *browserElement = [[QBooleanElement alloc] initWithTitle:@"橫向瀏覽" BoolValue:[[Setting shared].useNewBrowser boolValue]];
    browserElement.controllerAction = @"browserChange:";
    [switchsSection addElement:browserElement];
    return switchsSection;
}

- (QSection *)networkSection{
    //网络使用的 section
    QSection *networkSection = [[QSection alloc] initWithTitle:@"网络使用"];
    
    //最大重试次数
    QEntryElement *retryTimesElement = [[QEntryElement alloc] initWithTitle:@"允许重试次数" Value:[[Setting shared].retryTimes stringValue] Placeholder:@"输入一个整数"];
    retryTimesElement.controllerAction = @"retryTimesChange:";
    [networkSection addElement:retryTimesElement];
    
    //下载超时时间
    QEntryElement *timeoutSecondsElement = [[QEntryElement alloc] initWithTitle:@"图片下载超时时间" Value:[[Setting shared].timeoutSeconds stringValue] Placeholder:@"以秒为单位"];
    timeoutSecondsElement.controllerAction = @"timeoutSecondsChange:";
    [networkSection addElement:timeoutSecondsElement];
    
    //同时下载图片数量
    QEntryElement *loadingPicsAtSameTimeElement = [[QEntryElement alloc] initWithTitle:@"允许同时下载图片数量" Value:[[Setting shared].loadingPicsAtSameTime stringValue] Placeholder:@"输入一个整数"];
    loadingPicsAtSameTimeElement.controllerAction = @"loadingPicsAtSameTimeChange:";
    [networkSection addElement:loadingPicsAtSameTimeElement];
    
    return networkSection;
}

- (QSection *)changeColorSection {
    //選顏色
    QSection *changeColorSection = [[QSection alloc] initWithTitle:@"更換顏色"];
    changeColorSection.key = @"changeColorSection";
    QLabelElement *changeColorElement = [[QLabelElement alloc] initWithTitle:@"目前主題顏色" Value:[Setting shared].themeColor];
    [changeColorSection addElement:changeColorElement];
    QButtonElement *changeColorButton = [[QButtonElement alloc] initWithTitle:@"點我更換主題顏色"];
    @weakify(self);
    changeColorButton.onSelected = ^{
        @strongify(self);
        ThemeColorChangeViewController *themeColorChangeViewController = [ThemeColorChangeViewController new];
        themeColorChangeViewController.delegate = self;
        HentaiNavigationController *hentaiNavigation = [[HentaiNavigationController alloc] initWithRootViewController:themeColorChangeViewController];
        hentaiNavigation.autoRotate = NO;
        hentaiNavigation.hentaiMask = UIInterfaceOrientationMaskPortrait;
        [self presentViewController:hentaiNavigation animated:YES completion: ^{
        }];
    };
    [changeColorSection addElement:changeColorButton];
    return changeColorSection;
}

- (QSection *)cacheSizeSection {
    //暫存
    QSection *cacheSizeSection = [[QSection alloc] initWithTitle:@"暫存"];
    cacheSizeSection.key = @"cacheSizeSection";
    QLabelElement *cacheSizeElement = [[QLabelElement alloc] initWithTitle:@"占用容量" Value:@""];
    [cacheSizeSection addElement:cacheSizeElement];
    QButtonElement *earseCacheButton = [[QButtonElement alloc] initWithTitle:@"點我清空暫存"];
    @weakify(self);
    earseCacheButton.onSelected = ^{
        @strongify(self);
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
        [[FilesManager cacheFolder] rd:@"Hentai"];
        [HentaiCacheLibrary removeAllCacheInfo];
        [self cacheFolderSize];
    };
    [cacheSizeSection addElement:earseCacheButton];
    return cacheSizeSection;
}

- (QSection *)downloadSizeScetion {
    //下載
    QSection *downloadSizeSection = [[QSection alloc] initWithTitle:@"下載"];
    downloadSizeSection.key = @"downloadSizeSection";
    QLabelElement *downloadSizeElement = [[QLabelElement alloc] initWithTitle:@"占用容量" Value:@""];
    [downloadSizeSection addElement:downloadSizeElement];
    QButtonElement *earseDownloadButton = [[QButtonElement alloc] initWithTitle:@"點我清除雜亂占用"];
    @weakify(self);
    earseDownloadButton.onSelected = ^{
        @strongify(self);
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
    };
    [downloadSizeSection addElement:earseDownloadButton];
    return downloadSizeSection;
}

#pragma mark * actions

- (void)highResolutionChange:(QBooleanElement *)highResolutionElement {
    if (highResolutionElement.boolValue) {
        [UIAlertView hentai_alertViewWithTitle:@"注意~ O3O" message:@"開啟高清開關後, 儲存的圖片將明顯變大!\n效果會在下一次下載, 觀看時生效!" cancelButtonTitle:@"好~ O3O"];
    }
    [Setting shared].highResolution = @(highResolutionElement.boolValue);
}

- (void)browserChange:(QBooleanElement *)browserElement {
    if (browserElement.boolValue) {
        [UIAlertView hentai_alertViewWithTitle:@"注意~ O3O" message:@"目前這個功能僅在已下載功能中可使用~ O3O" cancelButtonTitle:@"好~ O3O"];
    }
    [Setting shared].useNewBrowser = @(browserElement.boolValue);
}

- (void)retryTimesChange:(QEntryElement *)retryTimesElement {
    [Setting shared].retryTimes = @([retryTimesElement.textValue integerValue]);
}

- (void)timeoutSecondsChange:(QEntryElement *)timeoutSecondsElement {
    [Setting shared].timeoutSeconds = @([timeoutSecondsElement.textValue doubleValue]);
}

- (void)loadingPicsAtSameTimeChange:(QEntryElement *)loadingPicsAtSameTimeElement {
    [Setting shared].loadingPicsAtSameTime = @([loadingPicsAtSameTimeElement.textValue integerValue]);
}

#pragma mark * size calculate

//code form FLEX
- (void)cacheFolderSize {
    __weak SettingV2ViewController *weakSelf = self;
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
            __strong SettingV2ViewController *strongSelf = weakSelf;
            
            NSString *sizeString = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
            QSection *sizeSection = [strongSelf.root sectionWithKey:@"cacheSizeSection"];
            QLabelElement *sizeElement = sizeSection.elements[0];
            sizeElement.value = sizeString;
            [strongSelf.quickDialogTableView reloadData];
        });
    });
}

//code form FLEX
- (void)documentFolderSize {
    __weak SettingV2ViewController *weakSelf = self;
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
            __strong SettingV2ViewController *strongSelf = weakSelf;
            
            NSString *sizeString = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
            QSection *sizeSection = [strongSelf.root sectionWithKey:@"downloadSizeSection"];
            QLabelElement *sizeElement = sizeSection.elements[0];
            sizeElement.value = sizeString;
            [strongSelf.quickDialogTableView reloadData];
        });
    });
}

#pragma mark - life cycle

- (id)init {
    self = [super initWithRoot:[self rootMaker]];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupItemsOnNavigation];
    [self cacheFolderSize];
    [self documentFolderSize];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[Setting shared] sync];
}

@end
