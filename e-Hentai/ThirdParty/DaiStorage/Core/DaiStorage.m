//
//  DaiStorage.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/8.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStorage.h"
#import <objc/runtime.h>

#import "DaiStorageProperty.h"
#import "DaiStorageTypeChecking.h"

@interface DaiStorage ()

@property (nonatomic, readonly) NSArray *listPropertys;

@end

@implementation DaiStorage

@dynamic listPropertys;

#pragma mark - dynamic

//http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
//列出當前 class 含有的 property 有哪些
- (NSArray *)listPropertys {
    NSMutableArray *propertyNames = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName) {
            NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
            NSString *propertyType = [self readableTypeForEncoding:[self attributesDictionaryForProperty:property][@"T"]];
            [propertyNames addObject:[DaiStorageProperty propertyName:propertyName type:propertyType]];
        }
    }
    free(properties);
    return propertyNames;
}

#pragma mark - readonly property

//回傳目前所含內容
- (NSDictionary *)storeContents {
	NSMutableDictionary *returnValues = [NSMutableDictionary dictionary];
	__weak id weakSelf = self;
	[self.listPropertys enumerateObjectsUsingBlock: ^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
        avoidPerformSelectorWarning(id currentProperty = [weakSelf performSelector:property.getter];)
        
        switch ([DaiStorageTypeChecking on:currentProperty]) {
            case DaiStorageTypeDaiStorage:
                avoidPerformSelectorWarning(currentProperty = [currentProperty performSelector:@selector(storeContents)];)
                break;
            case DaiStorageTypeDaiStorageArray:
            {
                DaiStorageArray *arrayProperty = currentProperty;
                NSMutableArray *newProperty = [NSMutableArray array];
                [currentProperty enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    switch ([DaiStorageTypeChecking on:obj]) {
                        case DaiStorageTypeDaiStorage:
                            avoidPerformSelectorWarning([newProperty addObject:[obj performSelector:@selector(storeContents)]];)
                            break;
                        default:
                            [newProperty addObject:[weakSelf reworkByExportRule:[DaiStorageProperty propertyType:arrayProperty.aClassName] reworkItem:obj]];
                            break;
                    }
                }];
                if (newProperty.count) {
                    currentProperty = newProperty;
                }
                else {
                    currentProperty = nil;
                }
                break;
            }
            case DaiStorageTypeOthers:
                currentProperty = [weakSelf reworkByExportRule:property reworkItem:currentProperty];
                break;
        }
        
        if (currentProperty) {
            returnValues[property.name] = currentProperty;
        }
	}];
    
    if (returnValues.count) {
        return returnValues;
    }
    else {
        return nil;
    }
}

#pragma mark - class method

//共用同一個對象
+ (instancetype)shared {
	if (!objc_getAssociatedObject(self, _cmd)) {
		objc_setAssociatedObject(self, _cmd, [[self class] new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - instance method

//單純從路徑匯入
- (void)importPath:(DaiStoragePath *)importPath {
    [self importPath:importPath defaultPath:nil];
}

//從 importpath 讀取資料, 不足的部分由 defaultpath 補齊
- (void)importPath:(DaiStoragePath *)importPath defaultPath:(DaiStoragePath *)defaultPath {
    NSDictionary *importContents = importPath ? [self jsonDataFromPath:importPath] : nil;
    NSDictionary *defaultContents = defaultPath ? [self jsonDataFromPath:defaultPath] : nil;
    [self restoreContents:importContents defaultContent:defaultContents];
}

//輸出至 exportpath
- (BOOL)exportPath:(DaiStoragePath *)exportPath {
    return [self jsonDataToPath:exportPath];
}

// handle 無法處理的型別
- (void)reworkRuleForClass:(__unsafe_unretained Class)aClass whenImport:(ImportRuleBlock)importRule whenExport:(ExportRuleBlock)exportRule {
    [self reworkRuleNamed:NSStringFromClass(aClass) whenImport:importRule whenExport:exportRule];
}

// handle 特定某一個名稱
- (void)reworkRuleForKeyPath:(NSString *)keyPath whenImport:(ImportRuleBlock)importRule whenExport:(ExportRuleBlock)exportRule {
    [self reworkRuleNamed:keyPath whenImport:importRule whenExport:exportRule];
}

- (void)removeAllObjects {
    __weak id weakSelf = self;
	[self.listPropertys enumerateObjectsUsingBlock: ^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
        switch ([DaiStorageTypeChecking on:property.aClass]) {
            case DaiStorageTypeDaiStorage:
            {
                avoidPerformSelectorWarning(DaiStorage *daiStorage = [weakSelf performSelector:property.getter];)
                [daiStorage removeAllObjects];
                break;
            }
            case DaiStorageTypeDaiStorageArray:
            {
                avoidPerformSelectorWarning(DaiStorageArray *daiStorageArray = [weakSelf performSelector:property.getter];)
                [daiStorageArray removeAllObjects];
                break;
            }
            default:
                avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:nil];)
                break;
        }
	}];
}

#pragma mark - private instance method

- (void)restoreContents:(NSDictionary *)importContents defaultContent:(NSDictionary *)defaultContent {
    __weak id weakSelf = self;
    [self.listPropertys enumerateObjectsUsingBlock:^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
        id importItem = nil;
        if (importContents[property.name]) {
            importItem = importContents[property.name];
        }
        else if (defaultContent[property.name]) {
            importItem = defaultContent[property.name];
        }
        
        if (importItem) {
            avoidPerformSelectorWarning(id currentProperty = [weakSelf performSelector:property.getter];)
            
            switch ([DaiStorageTypeChecking on:currentProperty]) {
                case DaiStorageTypeDaiStorage:
                    avoidPerformSelectorWarning([currentProperty performSelector:_cmd withObject:importItem withObject:nil];)
                    break;
                case DaiStorageTypeDaiStorageArray:
                {
                    DaiStorageArray *arrayProperty = currentProperty;
                    [arrayProperty removeAllObjects];
                    [importItem enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        switch ([DaiStorageTypeChecking on:arrayProperty.aClass]) {
                            case DaiStorageTypeDaiStorage:
                            {
                                id newStorage = [arrayProperty.aClass new];
                                avoidPerformSelectorWarning([newStorage performSelector:_cmd withObject:obj withObject:nil];)
                                [arrayProperty addObject:newStorage];
                                break;
                            }
                                
                            default:
                                [arrayProperty addObject:[weakSelf reworkByImportRule:[DaiStorageProperty propertyType:arrayProperty.aClassName] reworkItem:obj]];
                                break;
                        }
                    }];
                    avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:arrayProperty];)
                    break;
                }
                case DaiStorageTypeOthers:
                {
                    importItem = [weakSelf reworkByImportRule:property reworkItem:importItem];
                    avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:importItem];)
                    break;
                }
            }
        }
    }];
}

#pragma mark * rule import / export selector name

//用特定的名稱 runtime 建立 import / export methods
- (void)reworkRuleNamed:(NSString *)ruleNamed whenImport:(ImportRuleBlock)importRule whenExport:(ExportRuleBlock)exportRule {
    const char *blockEncoding = [[NSString stringWithFormat: @"%s%s%s%s", @encode(id), @encode(id), @encode(SEL), @encode(id)] UTF8String];
    
    //這邊用一個暫時的 property 取代下面要給 selector 名稱的部分
    DaiStorageProperty *tmpProperty = [DaiStorageProperty propertyName:ruleNamed];
    
    //add import rule method
    ReworkRuleBlock reworkImport = ^id(id self, id importValue) {
        return importRule(importValue);
    };
    IMP importIMP = imp_implementationWithBlock(reworkImport);
    class_addMethod([self class], tmpProperty.importName, importIMP, blockEncoding);
    
    //add export rule method
    ReworkRuleBlock reworkExport = ^id(id self, id exportValue) {
        return exportRule(exportValue);
    };
    IMP exportIMP = imp_implementationWithBlock(reworkExport);
    class_addMethod([self class], tmpProperty.exportName, exportIMP, blockEncoding);
}

//轉換 import 的物件
- (id)reworkByImportRule:(DaiStorageProperty *)property reworkItem:(id)reworkItem {
    id newItem = reworkItem;
    if (newItem) {
        if ([self respondsToSelector:property.importName]) {
            avoidPerformSelectorWarning(newItem = [self performSelector:property.importName withObject:newItem];)
        }
        else if ([self respondsToSelector:property.importType]) {
            avoidPerformSelectorWarning(newItem = [self performSelector:property.importType withObject:newItem];)
        }
    }
    return newItem;
}

//轉換 export 的物件
- (id)reworkByExportRule:(DaiStorageProperty *)property reworkItem:(id)reworkItem {
    id newItem = reworkItem;
    if (newItem) {
        if ([self respondsToSelector:property.exportName]) {
            avoidPerformSelectorWarning(newItem = [self performSelector:property.exportName withObject:newItem];)
        }
        else if ([self respondsToSelector:property.exportType]) {
            avoidPerformSelectorWarning(newItem = [self performSelector:property.exportType withObject:newItem];)
        }
    }
    return newItem;
}

#pragma mark * json data <-> dictionary

// json data 存入指定路徑
- (BOOL)jsonDataToPath:(DaiStoragePath *)path {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [path path], NSStringFromClass([self class])];
    if (self.storeContents) {
        return [[self jsonDataByContents:self.storeContents] writeToFile:filePath atomically:YES];
    }
    else {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        return !error ? YES : NO ;
    }
}

// contents 轉為 json data
- (NSData *)jsonDataByContents:(NSDictionary *)contents {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contents options:NSJSONWritingPrettyPrinted error:&error];
    NSAssert(!error, error.description);
    return jsonData;
}

//從指定路徑讀取 json data
- (NSDictionary *)jsonDataFromPath:(DaiStoragePath *)path {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [path path], NSStringFromClass([self class])];
    NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    return jsonData ? [self dictionaryByJsonData:jsonData] : nil;
}

// json data 轉換為 contents
- (NSDictionary *)dictionaryByJsonData:(NSData *)jsonData {
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSAssert(!error, error.description);
    return dictionary;
}

#pragma mark * list propertys in class

// from FLEX FLEXRuntimeUtility
- (NSDictionary *)attributesDictionaryForProperty:(objc_property_t)property {
    NSString *attributes = @(property_getAttributes(property));
    NSArray *attributePairs = [attributes componentsSeparatedByString:@","];
    NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionaryWithCapacity:[attributePairs count]];
    for (NSString *attributePair in attributePairs) {
        [attributesDictionary setObject:[attributePair substringFromIndex:1] forKey:[attributePair substringToIndex:1]];
    }
    return attributesDictionary;
}

// from FLEX FLEXRuntimeUtility
- (NSString *)readableTypeForEncoding:(NSString *)encodingString {
    if (!encodingString) {
        return nil;
    }
    
    const char *encodingCString = [encodingString UTF8String];
    if (encodingCString[0] == '@') {
        NSString *class = [encodingString substringFromIndex:1];
        class = [class stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if ([class length] == 0 || [class isEqual:@"?"]) {
            class = @"id";
        } else {
            class = [class stringByAppendingString:@""];
        }
        return class;
    }
    NSAssert(0, @"Only Support NSObject subclass");
    return encodingString;
}

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak id weakSelf = self;
        [self.listPropertys enumerateObjectsUsingBlock: ^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
            switch ([DaiStorageTypeChecking on:property.aClass]) {
                case DaiStorageTypeDaiStorage:
                    avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:[property.aClass new]];)
                    break;
                case DaiStorageTypeDaiStorageArray:
                    avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:[property.aClass new]];)
                    break;
                default:
                    break;
            }
        }];
    }
    return self;
}

@end