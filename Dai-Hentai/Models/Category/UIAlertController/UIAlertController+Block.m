//
//  UIAlertController+Block.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/3/25.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import "UIAlertController+Block.h"
#import <objc/runtime.h>

@implementation UIAlertController (Block)

#pragma mark - Class Method

+ (UIAlertController *)showAlertTitle:(NSString *)title message:(NSString *)message defaultOptions:(NSArray<NSString *> *)defaultOptions cancelOption:(NSString *)cancelOption handler:(void (^)(NSInteger optionIndex))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert setHandler:[handler copy]];

    __weak UIAlertController *weakAlert = alert;
    if (defaultOptions) {
        for (NSInteger index = 0; index < defaultOptions.count; index++) {
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:defaultOptions[index] style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
                if ([weakAlert handler]) {
                    [weakAlert handler](index + 1);
                }
            }];
            [alert addAction:defaultAction];
        }
    }
    
    if (cancelOption) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelOption style:UIAlertActionStyleCancel handler: ^(UIAlertAction *action) {
            if ([weakAlert handler]) {
                [weakAlert handler](0);
            }
        }];
        [alert addAction:cancelAction];
    }
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alert animated:YES completion:nil];
    return alert;
}

#pragma mark - Private Instance Method

- (void)setHandler:(void (^)(NSInteger optionIndex))handler {
    objc_setAssociatedObject(self, @selector(handler), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(NSInteger optionIndex))handler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)selfDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Instance Method

- (UIAlertController *(^)(NSTimeInterval time))dismissAfter {
    __weak UIAlertController *weakSelf = self;
    return ^UIAlertController *(NSTimeInterval time) {
        [weakSelf performSelector:@selector(selfDismiss) withObject:nil afterDelay:time];
        return weakSelf;
    };
}

@end
