//
//  DaiStorage.m
//  DaiStorage
//
//  Created by DaidoujiChen on 2015/4/8.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiStorage.h"
#import <objc/runtime.h>

#import "DaiStorageTypeChecking.h"
#import "DaiStoragePropertiesInObject.h"

@interface DaiStorage ()

@property (nonatomic, strong) NSMutableDictionary *propertiesMapping;
@property (nonatomic, copy) MigrationBlock migrations;

@end

@implementation DaiStorage

#pragma mark - readonly property

//回傳目前所含內容
- (NSDictionary *)storeContents {
	NSMutableDictionary *returnValues = [NSMutableDictionary dictionary];
	__weak typeof(self) weakSelf = self;
    [[self.propertiesMapping allValues] enumerateObjectsUsingBlock:^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
        avoidPerformSelectorWarning(id currentProperty = [weakSelf performSelector:property.getter];)
        switch ([DaiStorageTypeChecking on:property.propertyClass]) {
            case DaiStorageTypeDaiStorage:
            {
                avoidPerformSelectorWarning(currentProperty = [currentProperty performSelector:@selector(storeContents)];)
                break;
            }
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
    [self importPath:importPath defaultPath:defaultPath migrations:nil];
}

- (void)importPath:(DaiStoragePath *)importPath defaultPath:(DaiStoragePath *)defaultPath migrations:(MigrationBlock)migrations {
    self.migrations = migrations;
    NSMutableDictionary *importContents = importPath ? [self jsonDataFromPath:importPath] : nil;
    NSMutableDictionary *defaultContents = defaultPath ? [self jsonDataFromPath:defaultPath] : nil;
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
    __weak typeof(self) weakSelf = self;
    [[self.propertiesMapping allValues] enumerateObjectsUsingBlock: ^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
        switch ([DaiStorageTypeChecking on:property.propertyClass]) {
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

#pragma mark * restore

- (void)restoreContents:(NSMutableDictionary *)importContents defaultContent:(NSMutableDictionary *)defaultContent {
    
    //這一段處理 daistorage 物件中, 與讀取回來 json 內容匹配的物件
    __weak typeof(self) weakSelf = self;
    [[self.propertiesMapping allValues] enumerateObjectsUsingBlock:^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
        id anObject = [weakSelf extractObjectNamed:property.name inImportContents:importContents andDefaultContent:defaultContent];
        if (anObject) {
            [weakSelf restoreByProperty:property usingObject:anObject];
        }
    }];
    
    //這一段處理 json 內容內, 剩餘的物件
    if (self.migrations && (importContents.count || defaultContent.count)) {
        NSMutableSet *mergeKeys = [NSMutableSet set];
        [mergeKeys addObjectsFromArray:[importContents allKeys]];
        [mergeKeys addObjectsFromArray:[defaultContent allKeys]];
        
        __weak typeof(self) weakSelf = self;
        [mergeKeys enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            NSString *handleKeyPath = weakSelf.migrations(obj, importContents[obj], defaultContent[obj]);
            DaiStorageProperty *property = weakSelf.propertiesMapping[handleKeyPath];
            if (property) {
                id anObject = [weakSelf extractObjectNamed:obj inImportContents:importContents andDefaultContent:defaultContent];
                if (anObject) {
                    [weakSelf restoreByProperty:property usingObject:anObject];
                }
            }
        }];
    }
}

//根據 property 處理塞進去的物件
- (void)restoreByProperty:(DaiStorageProperty *)property usingObject:(id)anObject {
    switch ([DaiStorageTypeChecking on:property.propertyClass]) {
        case DaiStorageTypeDaiStorage:
        {
            avoidPerformSelectorWarning(id currentProperty = [self performSelector:property.getter];
                                        [currentProperty performSelector:@selector(restoreContents:defaultContent:) withObject:anObject withObject:nil];)
            break;
        }
        case DaiStorageTypeDaiStorageArray:
        {
            avoidPerformSelectorWarning(id currentProperty = [self performSelector:property.getter];)
            DaiStorageArray *arrayProperty = currentProperty;
            [arrayProperty removeAllObjects];
            [anObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                switch ([DaiStorageTypeChecking on:arrayProperty.aClass]) {
                    case DaiStorageTypeDaiStorage:
                    {
                        id newStorage = [arrayProperty.aClass new];
                        avoidPerformSelectorWarning([newStorage performSelector:@selector(restoreContents:defaultContent:) withObject:obj withObject:nil];)
                        [arrayProperty addObject:newStorage];
                        break;
                    }
                        
                    default:
                        [arrayProperty addObject:[self reworkByImportRule:[DaiStorageProperty propertyType:arrayProperty.aClassName] reworkItem:obj]];
                        break;
                }
            }];
            avoidPerformSelectorWarning([self performSelector:property.setter withObject:arrayProperty];)
            break;
        }
        case DaiStorageTypeOthers:
        {
            anObject = [self reworkByImportRule:property reworkItem:anObject];
            avoidPerformSelectorWarning([self performSelector:property.setter withObject:anObject];)
            break;
        }
    }
}

//從 import 及 default 內抽出相對應名稱的物件後, 將其清除掉
- (id)extractObjectNamed:(NSString *)name inImportContents:(NSMutableDictionary *)importContents andDefaultContent:(NSMutableDictionary *)defaultContent {
    id anObject = nil;
    if (importContents[name]) {
        anObject = importContents[name];
    }
    else if (defaultContent[name]) {
        anObject = defaultContent[name];
    }
    [importContents removeObjectForKey:name];
    [defaultContent removeObjectForKey:name];
    return anObject;
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
- (NSMutableDictionary *)jsonDataFromPath:(DaiStoragePath *)path {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [path path], NSStringFromClass([self class])];
    NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    return jsonData ? [self dictionaryByJsonData:jsonData] : nil;
}

// json data 轉換為 contents
- (NSMutableDictionary *)dictionaryByJsonData:(NSData *)jsonData {
    NSError *error = nil;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSAssert(!error, error.description);
    return dictionary;
}

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.propertiesMapping = [NSMutableDictionary dictionary];
        __weak typeof(self) weakSelf = self;
        [[DaiStoragePropertiesInObject enumerate:self] enumerateObjectsUsingBlock: ^(DaiStorageProperty *property, NSUInteger idx, BOOL *stop) {
            weakSelf.propertiesMapping[property.name] = property;
            switch ([DaiStorageTypeChecking on:property.propertyClass]) {
                case DaiStorageTypeDaiStorage:
                    avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:[property.propertyClass new]];)
                    break;
                case DaiStorageTypeDaiStorageArray:
                    avoidPerformSelectorWarning([weakSelf performSelector:property.setter withObject:[property.propertyClass new]];)
                    break;
                default:
                    break;
            }
        }];
    }
    return self;
}

@end