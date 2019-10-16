//
//  PrivateSettingViewController.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2018/3/11.
//  Copyright © 2018年 DaidoujiChen. All rights reserved.
//

#import "SettingViewController.h"
#import "EXTScope.h"

@interface SettingViewController () <UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ehListCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *ehAPICheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *exListCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *exAPICheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *historySizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *scrollDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lockThisAppLabel;

@property (nonatomic, strong) NSLock *sizeLock;
@property (nonatomic, strong) NSLock *statusCheckLock;
@property (nonatomic, strong) UITextField *cookieTextField;

@end
