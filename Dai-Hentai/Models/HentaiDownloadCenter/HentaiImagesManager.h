//
//  HentaiImagesManager.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/1/9.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HentaiInfo.h"
#import "HentaiParser.h"
#import "FilesManager.h"

@protocol HentaiImagesManagerDelegate;
@protocol HentaiImagesManagerInternalDelegate;

@interface HentaiImagesManager : NSObject

@property (nonatomic, weak) id<HentaiImagesManagerDelegate> delegate;
@property (nonatomic, weak) id<HentaiImagesManagerInternalDelegate> internalDelegate;
@property (nonatomic, readonly) NSMutableArray<NSString *> *imagePages;
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSNumber *> *> *heights;
@property (nonatomic, readonly) BOOL aliveForDownload;
@property (nonatomic, readonly) CGFloat downloadProgress;

+ (UIImage *)placeholder;

- (instancetype)initWith:(HentaiInfo *)info andParser:(Class)parser;
- (void)fetch:(void (^)(BOOL isExist))result;
- (void)downloadImageAt:(NSInteger)index;
- (void)loadImageAt:(NSInteger)index completion:(void (^)(UIImage *image))completion;
- (BOOL)isReadyAt:(NSInteger)index;
- (void)giveMeAll;
- (void)stop;

@end

@protocol HentaiImagesManagerDelegate <NSObject>

@required
- (void)imageHeightChangedAtPageIndex:(NSInteger)pageIndex;

@end

@protocol HentaiImagesManagerInternalDelegate <NSObject>

@required
- (void)downloadFinish:(HentaiInfo *)info;

@end
