//
//  DaiPortal+Sender.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/11.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiPortal+Sender.h"

#import "NSObject+DaiPortal.h"
#import "DaiPortal+Internal.h"

@implementation DaiPortal (Sender)

- (void)send:(DaiPortalPackage *)package {
    [self broadcastPackage:package];
}

- (void)send {
    [self send:[DaiPortalPackage empty]];
}

- (void)send:(DaiPortalPackage *)package completion:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:NO];
    [self send:package];
}

- (void)send:(DaiPortalPackage *)package completion_warp:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:YES];
    [self send:package];
}

- (void)completion:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:NO];
    [self send:[DaiPortalPackage empty]];
}

- (void)completion_warp:(VoidBlock)completion {
    [self signResultPortal:completion isWarp:YES];
    [self send:[DaiPortalPackage empty]];
}

#pragma mark - private

- (void)signResultPortal:(id)aBlock isWarp:(BOOL)isWarp {
    [self deallocObserver];
    
    if (isWarp) {
        [[self.dependObject portal:self.resultPortalIdentifier] recv_warp:aBlock];
    }
    else {
        [[self.dependObject portal:self.resultPortalIdentifier] recv:aBlock];
    }
}

@end
