//
//  SKTConversation.h
//  SupportKit
//
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SKTConversationDelegate;

@interface SKTConversation : NSObject

/**
 *  @abstract The total number of messages in the conversation, including user-generated messages.
 */
@property(readonly) NSUInteger messageCount;

/**
 *  @abstract Count of unread messages in the conversation.
 *
 *  @discussion The primary use of this property is to be able to display an indicator / badge when the conversation has unread messages.
 */
@property(readonly) NSUInteger unreadCount;

/**
 *  @abstract A delegate object for receiving notifications related to the conversation.
 *
 *  @see SKTConversationDelegate
 */
@property(weak) id<SKTConversationDelegate> delegate;

@end

/**
 *  @discussion Delegate protocol for events related to the conversation.
 *
 *  Creating a delegate is optional, and may be used to receive callbacks when important changes happen in the conversation.
 */
@protocol SKTConversationDelegate <NSObject>

/**
 *  @abstract Notifies the delegate of a change in unread message count.
 *  
 *  @discussion Called when conversation data is fetched from the server, or when the user enters the conversation screen.
 *
 *  This method is guaranteed to be called from the main thread.
 *
 *  @param conversation The conversation object that initiated the change
 *  @param unreadCount The new number of unread messages.
 */
-(void)conversation:(SKTConversation*)conversation unreadCountDidChange:(NSUInteger)unreadCount;

@end