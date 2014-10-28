//
//  SKTSettings.h
//  SupportKit
//
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @discussion Filtering mode to use with the -excludeSearchResultsIf:categories:sections: API of SKTSettings.
 *
 *  @see SKTSettings
 */
typedef NS_ENUM(NSUInteger, SKTSearchResultsFilterMode) {
    /**
     *  Filter out search results if they belong to any of the passed section ids.
     */
    SKTSearchResultIsIn,
    /**
     *  Filter out search results if they do not belong to any of the passed section ids.
     */
    SKTSearchResultIsNotIn
};

@interface SKTSettings : NSObject

/**
 *  @abstract Initializes a settings object with the given app token.
 *
 *  @param appToken A valid app token retrieved from the SupportKit web portal.
 */
+(instancetype)settingsWithAppToken:(NSString*)appToken;

/**
 *  @abstract Sets the filtering policy applied to user search results based on the given filter mode.
 *
 *  @discussion Filtering may only be configured once, and configuration must be done at init time or no filtering will be applied.
 *
 *  Filtering by category id is only possible for Zendesk instances that are using HelpCenter.
 *
 *  @see SKTSearchResultsFilterMode
 *
 *  @param filterMode The filter mode to use.
 *  @param categories Array of category ids on which to filter search results. Can be objects of type NSString or NSNumber.
 *  @param sections Array of section ids on which to filter search results. Can be objects of type NSString or NSNumber.
 */
-(void)excludeSearchResultsIf:(SKTSearchResultsFilterMode)filterMode categories:(NSArray*)categories sections:(NSArray*)sections;

/**
 *  @abstract The app token corresponding to your application.
 *
 *  @discussion App tokens are issued on the SupportKit web portal. This value may only be set once, and must be set at init time.
 */
@property(nonatomic, copy) NSString* appToken;

/**
 *  @abstract The base URL of your Zendesk knowledge base, to be used in constructing the search endpoint. 
 *
 *  @discussion This value may only be set once. If the knowledgeBaseURL is not specified at init time, search is disabled.
 *
 *  The URL must be fully qualified, including http or https (ex: "https://supportkit.zendesk.com").
 *
 *  The default value is nil.
 */
@property(nonatomic, copy) NSString* knowledgeBaseURL;

/**
 *  @abstract A boolean property that indicates whether to enable the app-wide gesture (two-finger swipe down) to present the SupportKit UI. 
 *
 *  @discussion Use option shift (⌥⇧) drag to perform the gesture on the simulator.
 *
 *  The default value is YES.
 */
@property BOOL enableAppWideGesture;

/**
 *  @abstract A boolean property that indicates whether to show a hint on how to perform the app-wide gesture when SupportKit is launched for the first time (without using the gesture).
 *
 *  @discussion The default value is YES.
 */
@property BOOL enableGestureHintOnFirstLaunch;

/**
 *  @abstract A Boolean property that indicates whether to show a local OS notification that brings your user into the conversation page once tapped.
 *
 *  @discussion The local OS notification is only shown if a user searched for help and left the app within 20 seconds, but without reading any KB articles or attempting to start a conversation.
 *
 *  The default value is YES.
 */
@property BOOL enableLocalNotification;

/**
 *  @abstract The accent color for the conversation screen.
 *
 *  @discussion Used as the color of user message bubbles, as well as the color of the send button and text input caret.
 *
 *  The default value is #00B0FF.
 */
@property UIColor* conversationAccentColor;

/**
 *  @abstract The status bar style to use on the conversation screen.
 *
 *  @discussion You should use this property if your app uses UIAppearance to style UINavigationBar, and your styling requires a specific status bar color.
 * 
 *  The default value is UIStatusBarStyleDefault.
 */
@property UIStatusBarStyle conversationStatusBarStyle;

@end
