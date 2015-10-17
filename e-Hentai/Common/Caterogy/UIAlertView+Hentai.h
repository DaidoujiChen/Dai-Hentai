//
//  UIAlertView+Hentai.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/1.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HentaiClickBlock)(UIAlertView *alertView, NSInteger clickIndex);
typedef void (^HentaiCancelBlock)(UIAlertView *alertView);
typedef void (^HentaiAlertBlock)(UIAlertView *alertView);

@interface UIAlertView (Hentai) <UIAlertViewDelegate>

+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onClickIndex:(HentaiClickBlock)clicked onCancel:(HentaiCancelBlock)cancelled;
+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertViewStyle)style willPresent:(HentaiAlertBlock)willPresent cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onClickIndex:(HentaiClickBlock)clicked onCancel:(HentaiCancelBlock)cancelled;

@property (nonatomic, copy) HentaiClickBlock hentai_clicked;
@property (nonatomic, copy) HentaiCancelBlock hentai_cancelled;
@property (nonatomic, copy) HentaiAlertBlock hentai_alert;

@end
