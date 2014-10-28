//
//  SKTUser.h
//  SupportKit
//
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKTUser : NSObject

/**
 *  @abstract Returns the object representing the current user.
 */
+(instancetype)currentUser;

/**
 *  @abstract Adds custom properties to the user. This info is used to provide more context around who a user is.
 *
 *  @discussion Keys must be of type NSString, and values must be of type NSString or NSNumber; any other type will be converted to NSString using the -description method.
 *  
 *  Example:
 *
 *      [user addProperties:@{ @"nickname" : @"Lil' Big Daddy Slim",  @"weight" : @650, @"premiumUser" : @YES }];
 *
 *  Changes to user properties will be uploaded each time the user sends a message, and will be displayed in the email you receive.
 *
 *  This API is additive, and subsequent calls will override values for the provided keys.
 *
 *  @param properties The properties to set for the current user.
 */
-(void)addProperties:(NSDictionary*)properties;

/**
 *  @abstract The user's first name, to be used as part of the display name when sending messages.
 */
@property(copy) NSString* firstName;

/**
 *  @abstract The user's last name, to be used as part of the display name when sending messages.
 */
@property(copy) NSString* lastName;

@end