#import <Foundation/Foundation.h>

@interface Pgyer : NSObject

+ (void)lastestInformationByShortcut:(NSString *)shortcut completion:(void (^)(NSDictionary *information))completion;

@end
