//
//  MessagingSystem.swift
//  Ripple
//
//  Created by nikitaivanov on 16/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class BackendlessMessaging : NSObject {
    
    class RippleMessage : Message {
        var messagesDBId: String?
        var isMessageDeleteNotification: Bool = false
        var isChatDeleteNotification: Bool = false
        
        init(messagesDBId: String) {
            self.messagesDBId = messagesDBId
        }
        
        override init() { }
    }
    
    private let messaging = Backendless.sharedInstance().messaging
    
    func notifyMessageSent(bMessage: ChatMessage, completion: (Bool, NSError?) -> Void) {
        _ = RippleMessage(messagesDBId: bMessage.objectId)
        
        /*let publishOptions = PublishOptions()
        publishOptions.publisherId = bMessage.senderId
        publishOptions.addHeader("toUser", value: bMessage.recipentId)
        
        publish(message: msg, options: publishOptions, completion: completion)*/
    }
    
    func notifyMessageDeleted(bMessage: ChatMessage, toUser user: Users, completion: (Bool, NSError?) -> Void) {
        let msg = RippleMessage(messagesDBId: bMessage.objectId)
        msg.isMessageDeleteNotification = true
        
        let publishOptions = PublishOptions()
        publishOptions.publisherId = UserManager().currentUser().objectId
        publishOptions.addHeader("toUser", value: user.objectId)
        
        publish(message: msg, options: publishOptions, completion: completion)
    }
    
    func notifyChatDeleted(withUserId userId: String, completion: (Bool, NSError?) -> Void) {
        let msg = RippleMessage()
        msg.isChatDeleteNotification = true
        
        let publishOptions = PublishOptions()
        publishOptions.publisherId = UserManager().currentUser().objectId
        publishOptions.addHeader("toUser", value: userId)
        
        publish(message: msg, options: publishOptions, completion: completion)
    }
    
    func subscribe(responce: ([RippleMessage]?, NSError?) -> Void) {
        let subscriptionOptions = SubscriptionOptions()
        subscriptionOptions.selector = "toUser = '\(UserManager().currentUser().objectId)'"
        
        subscribeWithOptions(subscriptionOptions, responce: responce)
    }

    func subscribe(toUser: Users, responce: ([RippleMessage]?, NSError?) -> Void) {
        let subscriptionOptions = SubscriptionOptions()
        subscriptionOptions.selector = "publisherId = '\(toUser.objectId)' and toUser = '\(UserManager().currentUser().objectId)'"
        
        subscribeWithOptions(subscriptionOptions, responce: responce)
    }

    private func publish(message msg: RippleMessage, options: PublishOptions, completion: (Bool, NSError?) -> Void) {
        messaging.publish(msg, publishOptions: options, response: { (messageStatus) in
            if messageStatus.valStatus() == FAILED {
                completion(false, ErrorHelper().getNSError(withCode: messageStatus.status.integerValue, withMessage: messageStatus.errorMessage))
            } else {
                completion(true, nil)
            }
        }, error: { (fault) in
            completion(false, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    private func subscribeWithOptions(options: SubscriptionOptions, responce: ([RippleMessage]?, NSError?) -> Void) {
        messaging.subscribe("default", subscriptionResponse: { (messages) in
            var rippleMessages = [RippleMessage]()
            for message in messages {
                if let bMessage = message as? RippleMessage {
                    rippleMessages.append(bMessage)
                }
            }
            responce(rippleMessages, nil)
        }, subscriptionError: { (fault) in
            responce(nil, ErrorHelper().convertFaultToNSError(fault))
        }, subscriptionOptions: options)
    }
}
