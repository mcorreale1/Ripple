//
//  MessagesManager.swift
//  Ripple
//
//  Created by nikitaivanov on 16/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class MessagesManager: NSObject {
    
    static let sharedInstance = MessagesManager()
    
    func getMessages(inChannel: ChatChannel, completion: ([Dictionary<String, AnyObject>]) -> Void) {
        ChatMessage.messagesIn(inChannel) {(result) in
            completion(MessagesManager().groupedMessages(result))
        }
    }
    
    func groupedMessages(messages: [ChatMessage]?) -> [Dictionary<String, AnyObject>] {
        var messagesResult = [Dictionary<String, AnyObject>]()
        
        guard var messageArray = messages else {
            return messagesResult
        }
                
        while messageArray.count > 0 {
            let message = messageArray.first!
            let day = message.created
            
            let calendar = NSCalendar.currentCalendar()
            var startOfTheDay: NSDate? = nil
            var endOfDay: NSDate? = nil
            var timeInterval: NSTimeInterval = 0
            
            calendar.rangeOfUnit(.Weekday, startDate: &startOfTheDay, interval: &timeInterval, forDate: day)
            endOfDay = startOfTheDay?.dateByAddingTimeInterval(timeInterval - 1)
            
            let firstFilterArray = messageArray.filter{$0.created!.isGreaterOrEqualThen(startOfTheDay!)}
            let result = firstFilterArray.filter{$0.created!.isLessThen(endOfDay!)}
            
            for _ in 0...result.count - 1 {
                messageArray.removeFirst()
            }
            
            let info = ["date" : day, "messages" : result]
            messagesResult.append(info)
        }

        return messagesResult
    }
    
    func sendMessage(owner: BackendlessUser, channel: ChatChannel, text: String?, completion: (ChatChannel?, NSError?) -> Void) {
        let message = ChatMessage()
        message.ownerId = owner.objectId
        message.message = text
        
        if channel.messages != nil {
            channel.messages?.append(message)
        } else {
            channel.messages = [message]
        }
        
        channel.lastMessage = message
        ChatChannel().dataStore().save(channel, response: { (entity) in
            completion(entity as? ChatChannel, nil)
            MessagesManager.sharedInstance.sendPush(channel.userAddressee()?.objectId, text: text)
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func subscribeToMyChannel() {
        let responder = Responder.init(responder: self, selResponseHandler: #selector(MessagesManager.sharedInstance.responseHandles(_:)), selErrorHandler: #selector(MessagesManager.sharedInstance.errorHandler(_:)))
        Backendless.sharedInstance().messaging.subscribe(UserManager().currentUser().objectId, responder: responder)
    }
    
    func responseHandles(id: AnyObject) {
        
    }
    
    func errorHandler(fault: Fault) {
        
    }
    
    func sendPush(toUser: String?, text: String?) {
        guard let objectId = toUser, let textMessage = text else {
            return
        }
        
        let publishOptions = PublishOptions()
        publishOptions.addHeader("ios-alert", value: "default")
        
        let message = (UserManager().currentUser().name ?? "") + ": " + textMessage
        
        Backendless.sharedInstance().messaging.publish(objectId, message: message, publishOptions: publishOptions, response: { (status) in
            
        }) { (fault) in
            
        }
    }
    
    // TODO: need refactoring
    
    func add(sender: Users, recipent: Users, text: String, completion: (ChatMessage?, NSError?) -> Void) {
        let message = ChatMessage()
        /*message.senderId = sender.objectId
        message.recipentId = recipent.objectId*/
        message.message = text
        
        ChatMessage().dataStore().save(message, response: { (entity) in
            completion(entity as? ChatMessage, nil)
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    
    func getMessagesWithMe(completion: ([ChatMessage]?, NSError?) -> Void) {
        let me = UserManager().currentUser()
        
        let query = BackendlessDataQuery()
        query.whereClause = "senderId = '\(me.objectId)' or recipentId = '\(me.objectId)'"
        query.queryOptions.sortBy(["created"])
        
        ChatMessage().dataStore().find(query, response: { (collection) in
            var messages = collection.data as? [ChatMessage] ?? [ChatMessage]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    messages.appendContentsOf(otherPageEvents?.data as? [ChatMessage] ?? [ChatMessage]())
                } else {
                    completion(messages, nil)
                }
            })
        }, error:  { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })
    }
    
    func getMessagesWithMeAndInterlocator(interlocator: Users, completion: ([ChatMessage]?, NSError?) -> Void) {
        /*let me = UserManager().currentUser()
        
        let query = BackendlessDataQuery()
        query.whereClause = "(senderId = '\(me.objectId)' and recipentId = '\(interlocator.objectId)') or (recipentId = '\(me.objectId)' and senderId = '\(interlocator.objectId)')"
        query.queryOptions.sortBy(["created"])
        
        ChatMessage().dataStore().find(query, response: { (collection) in
            var messages = collection.data as? [Message] ?? [Message]()
            collection.loadOtherPages({ (otherPageEvents) -> Void in
                if otherPageEvents != nil {
                    messages.appendContentsOf(otherPageEvents?.data as? [Message] ?? [Message]())
                } else {
                    completion(messages, nil)
                }
            })
            }, error:  { (fault) in
                completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })*/
    }
    
    func getMessage(byId id: String, completion: (ChatMessage?, NSError?) -> Void) {
        /*ChatMessage().dataStore().findID(id, response: { (message) in
            if let bMessage = message as? Message {
                completion(bMessage, nil)
            } else {
                completion(nil, ErrorHelper().getNSError(withCode: 0, withMessage: "cast error occured"))
            }
        }, error: { (fault) in
            completion(nil, ErrorHelper().convertFaultToNSError(fault))
        })*/
    }
    
    func deleteMessages(messages: [ChatMessage]) {
        for message in messages {
            message.delete({ (_) in })
        }
    }
}
