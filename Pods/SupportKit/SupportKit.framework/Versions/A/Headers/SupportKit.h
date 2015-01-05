//
//  SupportKit.h
//  SupportKit
//  version : 2.4.2
//
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTConversation.h"
#import "SKTSettings.h"
#import "SKTUser.h"

#define SUPPORTKIT_VERSION @"2.4.2"

@interface SupportKit : NSObject

/**
 *  @abstract Initialize the SupportKit SDK with the provided settings. 
 *
 *  @discussion This may only be called once (preferably, in application:didFinishLaunchingWithOptions:).
 *
 *  Use +settings to retrieve and modify the given settings object.
 *
 *  @see SKTSettings
 *
 *  @param settings The settings to use.
 */
+(void)initWithSettings:(SKTSettings*)settings;

/**
 *  @abstract Accessor method for the sdk settings.
 *
 *  @discussion Use this object to update settings at run time.
 *
 *  Note: Some settings may only be configured at init time. See the SKTSettings class reference for more information.
 *
 *  @see SKTSettings
 *
 *  @return Settings object passed in +initWithSettings:, or nil if +initWithSettings: hasn't been called yet.
 */
+(SKTSettings*)settings;

/**
 *  @abstract Presents the SupportKit Home screen.
 *
 *  @discussion Calling this method with search disabled and no recommendations configured is equivalent to calling +showConversation.
 *
 *  +initWithSettings: must have been called prior to calling show.
 */
+(void)show;

/**
 *  @abstract Presents the SupportKit Conversation page
 *
 *  @discussion Uses the top-most view controller of the application's main window as presenting view controller.
 *
 *  +initWithSettings: must have been called prior to calling showConversation.
 */
+(void)showConversation;

/**
 *  @abstract Displays the SupportKit gesture hint.
 *
 *  @discussion Upon completing (or skipping) the hint, the user will land on the SupportKit Home screen (equivalent to calling +show)
 *
 *  +initWithSettings: must have been called prior to calling showWithGestureHint.
 */
+(void)showWithGestureHint;

/**
 *  @abstract Set a list of recommendations that the user will see upon launching SupportKit.
 *  
 *  @discussion Recommendations are web resources that communicate important information to your users. For example: knowledge base articles, frequently asked questions, new feature announcements, etc... Recommendations are displayed when the +show API is called, or when SupportKit is launched using the app-wide gesture.
 *  
 *  Array items must be of type NSString, and should represent the URLs of the recommendations.
 *
 *  Passing nil will remove any existing default recommendations.
 *
 *  @param urlStrings The array of url strings.
 */
+(void)setDefaultRecommendations:(NSArray*)urlStrings;

/**
 *  @abstract Sets the top recommendation, to be displayed when the SupportKit UI is shown.
 *
 *  @discussion The top recommendation is displayed at the beginning of the recommendations list and takes precedence over default recommendations.
 *
 *  This should be used when there is a one-to-one mapping between an event (or error) that occurred in the app, and a corresponding article explaining or elaborating on that event.
 *
 *  Calling this method more than once will replace the previous top recommendation.
 *  Passing nil will remove the current top recommendation.
 *
 *  @param urlString The url of the article to be displayed.
 */
+(void)setTopRecommendation:(NSString*)urlString;

/**
 *  @abstract Sets the current user's first and last name to be used as a display name when sending messages.
 *
 *  @discussion This is a shortcut for -setFirstName and -setLastName on [SKTUser currentUser]
 *
 *  @see SKTUser
 *
 *  @param firstName The first name of the user
 *  @param lastName The last name of the user
 */
+(void)setUserFirstName:(NSString*)firstName lastName:(NSString*)lastName;

/**
 *  @abstract Tracks an app event, and processes any whispers associated with that event.
 *
 *  @discussion Whispers can be configured in the SupportKit admin panel.
 *
 *  Whispers can only be fulfilled once per app user, and tracking an event after the whisper has been fulfilled will have no effect.
 *
 *  @param eventName The name of the event to track. This should match a whisper created on the admin panel for your app.
 */
+(void)track:(NSString*)eventName;

/**
 *  @abstract Accessor method for the current conversation.
 *
 *  @see SKTConversation
 *
 *  @return Current conversation, or nil if +initWithSettings: hasn't been called yet.
 */
+(SKTConversation*)conversation;

@end
