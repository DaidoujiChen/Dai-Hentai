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

@dynamic hentaiClicked, hentaiCancelled;

#pragma mark - dynamic

- (void)setHentaiClicked:(HentaiClickBlock)clicked {
	objc_setAssociatedObject(self, @selector(hentaiClicked), clicked, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (HentaiClickBlock)hentaiClicked {
	return objc_getAssociatedObject(self, _cmd);
}

- (void)setHentaiCancelled:(HentaiCancelBlock)cancelled {
	objc_setAssociatedObject(self, @selector(hentaiCancelled), cancelled, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (HentaiCancelBlock)hentaiCancelled {
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
	alert.hentaiClicked = clicked;
	alert.hentaiCancelled = cancelled;
    
	for (NSString *buttonTitle in otherButtons) {
		[alert addButtonWithTitle:buttonTitle];
	}
	[alert show];
	return alert;
}

#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
		if (alertView.hentaiCancelled) {
			alertView.hentaiCancelled();
		}
	}
	else {
		if (alertView.hentaiClicked) {
			alertView.hentaiClicked(buttonIndex - 1);
		}
	}
}

@end
