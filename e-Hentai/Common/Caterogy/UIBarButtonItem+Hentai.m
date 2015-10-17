//
//  UIBarButtonItem+Hentai.m
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/7/30.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "UIBarButtonItem+Hentai.h"
#import <objc/runtime.h>

@implementation UIBarButtonItem (Hentai)

#pragma mark - private instance method

- (void)invokeBlockAction {
    BlockAction blockAction = [self blockAction];
    if (blockAction) {
        blockAction();
    }
}

#pragma mark - instance method

- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction {
    [self setBlockAction:blockAction];
    self = [self initWithImage:image style:style target:self action:@selector(invokeBlockAction)];
    return self;
}

- (instancetype)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction {
    [self setBlockAction:blockAction];
    self = [self initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:self action:@selector(invokeBlockAction)];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction {
    [self setBlockAction:blockAction];
    self = [self initWithTitle:title style:style target:self action:@selector(invokeBlockAction)];
    return self;
}

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem blockAction:(BlockAction)blockAction {
    [self setBlockAction:blockAction];
    self = [self initWithBarButtonSystemItem:systemItem target:self action:@selector(invokeBlockAction)];
    return self;
}

#pragma mark - runtime objects

- (void)setBlockAction:(BlockAction)blockAction {
    objc_setAssociatedObject(self, @selector(blockAction), blockAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BlockAction)blockAction {
    return objc_getAssociatedObject(self, _cmd);
}

@end
