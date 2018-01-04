//
//  GalleryViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/14.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HentaiInfo.h"

@interface GalleryViewController : UIViewController

@property (nonatomic, strong) HentaiInfo *info;
@property (nonatomic, strong) Class parser;

@end
