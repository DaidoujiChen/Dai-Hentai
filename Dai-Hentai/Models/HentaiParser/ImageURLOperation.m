//
//  ImageURLOperation.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/17.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "ImageURLOperation.h"
#import <objc/runtime.h>
#import "HentaiParser.h"

@interface HentaiParser (PrivateMethods)

+ (void)parseImageURL:(NSString *)gid page:(NSString *)page imgkey:(NSString *)imgkey showKey:(NSString *)showKey completion:(void (^)(HentaiParserStatus status, NSString *imageURL))completion;
+ (void)parseShowKey:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSString *showKey))completion;

@end

@interface ImageURLOperation ()

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, copy) void (^completion)(HentaiParserStatus status, NSString *imageURL);

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@end

@implementation ImageURLOperation

#pragma mark - Private Class Method

+ (NSMutableDictionary *)showKeys {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Private Instance Method

#pragma mark * Methods to Override

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    if ([self isCancelled]) {
        [self operationFinish];
        return;
    }
    [self operationStart];
    
    //https://e-hentai.org/s/1a8e31f2c6/1029334-2
    //                          -2        -1
    NSArray<NSString *> *splitStrings = [self.urlString componentsSeparatedByString:@"/"];
    NSString *gid = [splitStrings.lastObject componentsSeparatedByString:@"-"][0];
    NSString *page = [splitStrings.lastObject componentsSeparatedByString:@"-"][1];
    NSString *imgkey = splitStrings[splitStrings.count - 2];
    
    if ([ImageURLOperation showKeys][gid]) {
        [self passToParser:gid imgkey:imgkey page:page];
    }
    else {
        __weak ImageURLOperation *weakSelf = self;
        [self.parser parseShowKey:self.urlString completion: ^(HentaiParserStatus status, NSString *showKey) {
            if (weakSelf) {
                __strong ImageURLOperation *strongSelf = weakSelf;
                if (status == HentaiParserStatusSuccess) {
                    [ImageURLOperation showKeys][gid] = showKey;
                    [strongSelf passToParser:gid imgkey:imgkey page:page];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf) {
                            __strong ImageURLOperation *strongSelf = weakSelf;
                            strongSelf.completion(status, showKey);
                            [strongSelf operationFinish];
                        }
                    });
                }
            }
        }];
    }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return YES;
}

#pragma mark * Operation Status

- (void)operationStart {
    self.isFinished = NO;
    self.isExecuting = YES;
}

- (void)operationFinish {
    self.isFinished = YES;
    self.isExecuting = NO;
}

#pragma mark * Misc

- (void)passToParser:(NSString *)gid imgkey:(NSString *)imgkey page:(NSString *)page {
    
    NSString *showKey = [ImageURLOperation showKeys][gid];
    __weak ImageURLOperation *weakSelf = self;
    [self.parser parseImageURL:gid page:page imgkey:imgkey showKey:showKey completion: ^(HentaiParserStatus status, NSString *imageURL) {
        if (weakSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    __strong ImageURLOperation *strongSelf = weakSelf;
                    if (status != HentaiParserStatusSuccess) {
                        [[ImageURLOperation showKeys] removeObjectForKey:gid];
                    }
                    strongSelf.completion(status, imageURL);
                    [strongSelf operationFinish];
                }
            });
        }
    }];
}

#pragma mark - Life Cycle

- (instancetype)initWithURLString:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSString *imageURL))completion {
    self = [super init];
    if (self) {
        self.urlString = urlString;
        self.completion = completion;
    }
    return self;
}

@end
