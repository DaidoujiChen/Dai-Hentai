//
//  SliderViewController.h
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/10/2.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "IIViewDeckController.h"

#import "MainViewController.h"
#import "MenuViewController.h"
#import "DownloadManagerViewController.h"

@interface SliderViewController : IIViewDeckController <MainViewControllerDelegate, MenuViewControllerDelegate, IIViewDeckControllerDelegate, OpenMenuProtocol>

@end
