//
//  DaiStorageDefine.h
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/10.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#ifndef DaiStorage_DaiStorageDefine_h
#define DaiStorage_DaiStorageDefine_h

#define avoidPerformSelectorWarning(CODE) \
	_Pragma("clang diagnostic push") \
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
	CODE \
	_Pragma("clang diagnostic pop")

#define DaiStorageArrayConverter(AnyClass) \
@interface AnyClass##Array : DaiStorageArray \
@end

typedef id (^ReworkRuleBlock)(id self, id importValue);
typedef id (^ImportRuleBlock)(NSString *importValue);
typedef NSString * (^ExportRuleBlock)(id exportValue);
typedef NSString * (^MigrationBlock)(NSString *originKeyPath, NSString *importValue, NSString *defaultValue);

#endif
