//
//  UIAlertController+Block.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/25.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Block)

+ (UIAlertController *)alertTitle:(NSString *)title message:(NSString *)message defaultOptions:(NSArray<NSString *> *)defaultOptions cancelOption:(NSString *)cancelOption handler:(void (^)(NSInteger optionIndex))handler;

@end
