//
//  DaiPortal.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiPortal.h"

#import <objc/runtime.h>
#import "DaiPortalWarehouse.h"
#import "DaiPortalBlockAnalysis.h"
#import "DaiPortalPerformHelper.h"

//https://github.com/krzysztofzablocki/NSObject-SFExecuteOnDealloc
//用來檢測物件是否 dealloc

@interface SFExecuteOnDeallocInternalObject : NSObject

@property (nonatomic, copy) void (^block)();

- (id)initWithBlock:(void (^)(void))aBlock;

@end

@implementation SFExecuteOnDeallocInternalObject

- (id)initWithBlock:(void (^)(void))aBlock {
    self = [super init];
    if (self) {
        self.block = aBlock;
    }
    return self;
}

- (void)dealloc {
    if (self.block) {
        self.block();
    }
}

@end

@interface DaiPortalPackage ()

@property (nonatomic, strong) id anyObject;

@end

@implementation DaiPortalPackage

+ (DaiPortalPackage *)empty {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = nil;
    return newResult;
}

+ (DaiPortalPackage *)item:(id)anObject {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = @[anObject];
    return newResult;
}

+ (DaiPortalPackage *)items:(id)firstItem, ...NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *objects = [NSMutableArray array];
    if (firstItem) {
        va_list list;
        id listObject = firstItem;
        va_start(list, firstItem);
        do {
            if (listObject) {
                [objects addObject:listObject];
            }
            listObject = va_arg(list, id);
        }
        while (listObject != nil);
        va_end(list);
    }
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = objects;
    return newResult;
}

@end

@interface DaiPortal ()

@property (nonatomic, copy) id actionBlock;
@property (nonatomic, readonly) NSUInteger argumentsInBlock;
@property (nonatomic, assign) BOOL isDisposable;
@property (nonatomic, assign) BOOL isWarp;

- (void)deallocObserver;
- (void)signPortal:(id)block;
- (void)broadcastObjects:(NSArray *)objects toIdentifier:(NSString *)identifier;
- (void)handleRecvNotification:(NSNotification *)reciverNotification;

@end

@implementation DaiPortal

- (id)init {
    self = [super init];
    if (self) {
        self.isWarp = NO;
        self.isDisposable = NO;
    }
    return self;
}

- (void)setActionBlock:(id)actionBlock {
    _actionBlock = [actionBlock copy];
    _argumentsInBlock = [DaiPortalBlockAnalysis argumentsInBlock:actionBlock] - 1;
}

//用來監測物件是否該被移除
- (void)deallocObserver {
    if (!objc_getAssociatedObject(self.dependObject, _cmd)) {
        SFExecuteOnDeallocInternalObject *internalObject = [[SFExecuteOnDeallocInternalObject alloc] initWithBlock: ^{
            [DaiPortalWarehouse resign:self.dependObject];
        }];
        objc_setAssociatedObject(self.dependObject, _cmd, internalObject, OBJC_ASSOCIATION_RETAIN);
    }
}

//把新的傳送門登記到倉庫中
- (void)signPortal:(id)block {
    [self deallocObserver];
    self.actionBlock = block;
    [[DaiPortalWarehouse daiPortalNotificationCenter] addObserver:self selector:@selector(handleRecvNotification:) name:self.identifier object:nil];
    [DaiPortalWarehouse sign:self];
}

//把資料群發出去給想收的人
- (void)broadcastObjects:(NSArray *)objects toIdentifier:(NSString *)identifier {
    [[DaiPortalWarehouse daiPortalNotificationCenter] postNotificationName:identifier object:objects userInfo:@{ @"source": self.dependObject }];
}

//控制接到的通知
- (void)handleRecvNotification:(NSNotification *)notification {
    //如果依附的對象已經被刪除, 這邊則直接將他從 list 移除
    if (!self.dependObject) {
        [DaiPortalWarehouse removeDisposable:self];
        return;
    }
    
    //要先看傳送過來的數量是不是跟要輸出的數量一致
    if (self.argumentsInBlock == [notification.object count]) {
        //根據 block 的類型又可以分為回傳 void 及 DaiPortalPackage 兩種
        switch ([DaiPortalBlockAnalysis returnTypeInBlock:self.actionBlock]) {
            case DaiPortalBlockAnalysisReturnTypeID:
            {
                if (self.isWarp) {
                    __weak DaiPortal *weakSelf = self;
                    [self warp: ^{
                        DaiPortalPackage *result = [DaiPortalPerformHelper idPerformObjects:notification.object usingBlock:weakSelf.actionBlock];
                        [weakSelf weft: ^{
                            if (result && result.anyObject) {
                                [weakSelf broadcastObjects:result.anyObject toIdentifier:[NSString stringWithFormat:@"%@_result", weakSelf.identifier]];
                            }
                            [weakSelf disposableCheck];
                        }];
                    }];
                }
                else {
                    DaiPortalPackage *result = [DaiPortalPerformHelper idPerformObjects:notification.object usingBlock:self.actionBlock];
                    if (result && result.anyObject) {
                        [self broadcastObjects:result.anyObject toIdentifier:[NSString stringWithFormat:@"%@_result", self.identifier]];
                    }
                    [self disposableCheck];
                }
                break;
            }
                
            case DaiPortalBlockAnalysisReturnTypeVoid:
            {
                if (self.isWarp) {
                    __weak DaiPortal *weakSelf = self;
                    [self warp: ^{
                        [DaiPortalPerformHelper voidPerformObjects:notification.object usingBlock:weakSelf.actionBlock];
                        [weakSelf weft: ^{
                            [weakSelf disposableCheck];
                        }];
                    }];
                }
                else {
                    [DaiPortalPerformHelper voidPerformObjects:notification.object usingBlock:self.actionBlock];
                    [self disposableCheck];
                }
                break;
            }
                
            case DaiPortalBlockAnalysisReturnTypeUnknow:
            {
                NSLog(@"應該沒有人會到這邊吧, O口O!");
                break;
            }
        }
    }
    else {
        NSLog(@"從 %@ 傳送往 %@, 識別為 <%@> 的參數數量不匹配.", notification.userInfo[@"source"], self.dependObject, self.identifier);
    }
}

- (void)disposableCheck {
    //免洗的傳送門用一次就丟掉
    if (self.isDisposable) {
        [DaiPortalWarehouse removeDisposable:self];
    }
}

- (void)warp:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)weft:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

@end

@implementation DaiPortal (Reciver)

- (void)recv:(VoidBlock)aBlock {
    [self signPortal:aBlock];
}

- (void)recv_warp:(VoidBlock)aBlock {
    self.isWarp = YES;
    [self recv:aBlock];
}

- (void)respond:(PackageBlock)aBlock {
    [self signPortal:aBlock];
}

- (void)respond_warp:(PackageBlock)aBlock {
    self.isWarp = YES;
    [self respond:aBlock];
}

@end

@implementation DaiPortal (Sender)

- (void)send:(DaiPortalPackage *)package {
    [self broadcastObjects:package.anyObject toIdentifier:self.identifier];
}

- (void)send {
    [self send:[DaiPortalPackage empty]];
}

- (void)send:(DaiPortalPackage *)package completion:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:NO];
    [self send:package];
}

- (void)send:(DaiPortalPackage *)package completion_warp:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:YES];
    [self send:package];
}

- (void)completion:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:NO];
    [self send:[DaiPortalPackage empty]];
}

- (void)completion_warp:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:YES];
    [self send:[DaiPortalPackage empty]];
}

#pragma mark - private

- (void)signResultPortal:(id)block isWarp:(BOOL)isWarp {
    [self deallocObserver];
    DaiPortal *resultPortal = [DaiPortal new];
    resultPortal.identifier = [NSString stringWithFormat:@"%@_result", self.identifier];
    resultPortal.dependObject = self.dependObject;
    resultPortal.actionBlock = block;
    resultPortal.isDisposable = YES;
    resultPortal.isWarp = isWarp;
    [[DaiPortalWarehouse daiPortalNotificationCenter] addObserver:resultPortal selector:@selector(handleRecvNotification:) name:resultPortal.identifier object:nil];
    [DaiPortalWarehouse sign:resultPortal];
}

@end
