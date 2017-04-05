//
//  RelatedViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/4/3.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HentaiInfo.h"

@interface RelatedViewController : UIViewController

@property (nonatomic, strong) HentaiInfo *info;
@property (nonatomic, strong) NSMutableArray<NSString *> *selectedWords;

@end
