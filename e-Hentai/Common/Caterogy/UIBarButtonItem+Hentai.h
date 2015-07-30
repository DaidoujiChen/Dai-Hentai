//
//  UIBarButtonItem+Hentai.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2015/7/30.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BlockAction)(void);

@interface UIBarButtonItem (Hentai)

- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction;
- (instancetype)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction;
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction;
- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem blockAction:(BlockAction)blockAction;

@end
