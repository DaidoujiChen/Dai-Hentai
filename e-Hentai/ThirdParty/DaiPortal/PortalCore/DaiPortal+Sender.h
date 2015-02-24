//
//  DaiPortal+Sender.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/11.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

//用來傳送資料的部分, 負責觸發已建立的傳送門, 帶上 warp 結尾的 method, block 內的 code 會以非同步方式運行

#import "DaiPortal.h"

@interface DaiPortal (Sender)

//send 為傳一個以上的東西過去, send 則為純粹的觸發
- (void)send:(DaiPortalPackage *)package;
- (void)send;

//帶上 result 的話可以收到回傳的訊息
- (void)send:(DaiPortalPackage *)package completion:(VoidBlock)completion;
- (void)send:(DaiPortalPackage *)package completion_warp:(VoidBlock)completion;
- (void)completion:(VoidBlock)completion;
- (void)completion_warp:(VoidBlock)completion;

@end
