//
//  AuthHelper.m
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/2/13.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "AuthHelper.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <objc/runtime.h>
#import "EXTScope.h"

@implementation AuthHelper

#pragma mark - Private Class Method

+ (LAContext *)context {
    LAContext *context = objc_getAssociatedObject(self, _cmd);
    if (context) {
        return context;
    }
    [self setContext:[LAContext new]];
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setContext:(LAContext *)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Class Method

+ (void)refreshAuth {
    [self setContext:[LAContext new]];
}

+ (BOOL)canLock {
    return [[self context] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
}

+ (void)checkFor:(NSString *)reason completion:(void (^)(BOOL pass))completion {
    if ([self canLock]) {
        [[self context] evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply: ^(BOOL success, NSError *error) {
            
            if (error) {
                NSLog(@"%@", error);
            }
            
            if (!completion) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success && error == nil);
            });
        }];
    }
    else {
        NSLog(@"鎖不住 o.o");
    }
}

@end
