//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "DBUserPreference.h"
#import "SettingViewController.h"

@interface NSObject (OwO)

- (BOOL)respondsOwO:(NSString *)selector;
- (id)performOwO:(NSString *)aSelector withObject:(id)object;

@end

@implementation NSObject (OwO)

- (BOOL)respondsOwO:(NSString *)selector {
    return [self respondsToSelector:NSSelectorFromString(selector)];
}

- (id)performOwO:(NSString *)aSelector withObject:(id)object {
    return [self performSelector:NSSelectorFromString(aSelector) withObject:object];
}

@end
