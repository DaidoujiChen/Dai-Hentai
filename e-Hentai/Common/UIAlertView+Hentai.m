//
//  UIAlertView+Hentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/1.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "UIAlertView+Hentai.h"

#import <objc/runtime.h>

@implementation UIAlertView (Hentai)

@dynamic hentai_clicked, hentai_cancelled;

#pragma mark - dynamic

- (void)setHentai_clicked:(HentaiClickBlock)clicked {
	objc_setAssociatedObject(self, @selector(hentai_clicked), clicked, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (HentaiClickBlock)hentai_clicked {
	return objc_getAssociatedObject(self, _cmd);
}

- (void)setHentai_cancelled:(HentaiCancelBlock)cancelled {
	objc_setAssociatedObject(self, @selector(hentai_cancelled), cancelled, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (HentaiCancelBlock)hentai_cancelled {
	return objc_getAssociatedObject(self, _cmd);
}

- (void)setHentai_account:(HentaiAccountBlock)hentai_account {
    objc_setAssociatedObject(self, @selector(hentai_account), hentai_account, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (HentaiAccountBlock)hentai_account {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - instance method

+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message {
	return [UIAlertView hentai_alertViewWithTitle:title message:message cancelButtonTitle:@"取消"];
}

+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	[alert show];
	return alert;
}

+ (UIAlertView *)hentai_alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onClickIndex:(HentaiClickBlock)clicked onCancel:(HentaiCancelBlock)cancelled {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:[self class] cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	alert.hentai_clicked = clicked;
	alert.hentai_cancelled = cancelled;
    
	for (NSString *buttonTitle in otherButtons) {
		[alert addButtonWithTitle:buttonTitle];
	}
	[alert show];
	return alert;
}

#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
		if (alertView.hentai_cancelled) {
			alertView.hentai_cancelled();
		}
	}
	else {
		if (alertView.hentai_clicked) {
			alertView.hentai_clicked(buttonIndex - 1);
		}
	}
}

@end
