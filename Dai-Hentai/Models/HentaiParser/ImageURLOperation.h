//
//  ImageURLOperation.h
//  Dai-Hentai
//
//  Created by DaidoujiChen on 2017/2/17.
//  Copyright © 2017年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HentaiParser.h"

@interface ImageURLOperation : NSOperation

@property (nonatomic, strong) Class parser;

- (instancetype)initWithURLString:(NSString *)urlString completion:(void (^)(HentaiParserStatus status, NSString *imageURL))completion;

@end
