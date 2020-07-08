//
//  SettingViewController+ListAndAPIStatus.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/11.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SettingViewController+ListAndAPIStatus.h"
#import <objc/runtime.h>
#import "EHentaiParser.h"
#import "ExHentaiParser.h"
#import "Dai_Hentai-Swift.h"

typedef enum {
    LocalStatusTypeInit = 100,
    LocalStatusTypeExNotLogin
} LocalStatusType;

@implementation SettingViewController (ListAndAPIStatus)

#pragma mark - Private Class Method

+ (NSDictionary<NSNumber *, NSDictionary *> *)statusInfos {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, @{ @(HentaiParserStatusParseFail): @{ @"color": [UIColor redColor],
                                                                                   @"list": @"解析失敗",
                                                                                   @"api": @"不知道" },
                                                @(HentaiParserStatusNetworkFail): @{ @"color": [UIColor redColor],
                                                                                   @"list": @"網路錯誤",
                                                                                   @"api": @"網路錯誤" },
                                                @(HentaiParserStatusSuccess): @{ @"color": [UIColor greenColor],
                                                                                 @"list": @"成功",
                                                                                 @"api": @"成功" },
                                                @(LocalStatusTypeInit): @{ @"color": [UIColor blackColor],
                                                                           @"list": @"測試中...",
                                                                           @"api": @"測試中..." },
                                                @(LocalStatusTypeExNotLogin): @{ @"color": [UIColor redColor],
                                                                               @"list": @"未登入 EX",
                                                                               @"api": @"未登入 EX" }
                                               }, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Private Instance Method

- (UIViewController *)checkViewControllerBy:(NSString *)reuseIdentifier {
    CheckPageViewController *checkViewController;
    if ([reuseIdentifier isEqualToString:@"EhListCheckCell"]) {
        checkViewController = [[CheckPageViewController alloc] initWithUrlString:@"https://e-hentai.org/"];
    }
    else {
        checkViewController = [[CheckPageViewController alloc] initWithUrlString:@"https://exhentai.org/"];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:checkViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    return navigationController;
}

- (void)displayListAndAPIStatus {
    BOOL cookieExist = [ExCookie isExist];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        if ([self.statusCheckLock tryLock]) {
            
            // 設定 init 字樣
            [self localStatus:LocalStatusTypeInit listLabel:self.ehListCheckLabel apiLabel:self.ehAPICheckLabel];
            [self localStatus:LocalStatusTypeInit listLabel:self.exListCheckLabel apiLabel:self.exAPICheckLabel];
            
            // 測試 eh 是否正常
            [self statusCheck:HentaiParserTypeEh listLabel:self.ehListCheckLabel apiLabel:self.ehAPICheckLabel];
            
            // 如果沒有 cookies, 則直接設定字樣
            if (!cookieExist) {
                [self localStatus:LocalStatusTypeExNotLogin listLabel:self.exListCheckLabel apiLabel:self.exAPICheckLabel];
            }
            // 測試 ex 是否正常
            else {
                [self statusCheck:HentaiParserTypeEx listLabel:self.exListCheckLabel apiLabel:self.exAPICheckLabel];
            }
            [self.statusCheckLock unlock];
        }
    });
}

- (void)localStatus:(LocalStatusType)type listLabel:(UILabel *)listLabel apiLabel:(UILabel *)apiLabel {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = [SettingViewController statusInfos][@(type)];
        listLabel.textColor = info[@"color"];
        listLabel.text = info[@"list"];
        apiLabel.textColor = info[@"color"];
        apiLabel.text = info[@"api"];
    });
}

- (void)statusCheck:(HentaiParserType)type listLabel:(UILabel *)listLabel apiLabel:(UILabel *)apiLabel {
    Class parser = type == HentaiParserTypeEh ? [EHentaiParser class] : [ExHentaiParser class];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [parser requestListUsingFilter:@"" completion: ^(HentaiParserStatus status, NSArray<HentaiInfo *> *infos) {
        
        // 這邊是在 main thread 裡面
        NSDictionary *info = [SettingViewController statusInfos][@(status)];
        listLabel.textColor = info[@"color"];
        listLabel.text = info[@"list"];
        apiLabel.textColor = info[@"color"];
        apiLabel.text = info[@"api"];
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

@end
