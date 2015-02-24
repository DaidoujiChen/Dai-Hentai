//
//  DaiPortal+Reciver.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/11.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

//建立用來接收資料的部分, 收到觸發時會運行 aBlock 的內容, 帶上 warp 結尾的 method, block 內的 code 會以非同步方式運行

#import "DaiPortal.h"

@interface DaiPortal (Reciver)

- (void)recv:(VoidBlock)aBlock;
- (void)recv_warp:(VoidBlock)aBlock;
- (void)respond:(PackageBlock)aBlock;
- (void)respond_warp:(PackageBlock)aBlock;

@end
