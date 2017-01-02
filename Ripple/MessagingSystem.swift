//
//  MessagingSystem.swift
//  Ripple
//
//  Created by nikitaivanov on 16/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class MessagingSystem : NSObject {
    
    let me = UserManager().currentUser()
    
    struct Chat {
        var interlocutor: Users
        var messages = [Message]()
    }
    
    func send(message: String?, inChannel: ChatChannel, toUser: BackendlessUser?, completion: (ChatChannel?, NSError?) -> Void) {
        MessagesManager.sharedInstance.sendMessage(UserManager().currentUser(), channel: inChannel, text: message) { (channel, error) in
            completion(channel, error)
        }
    }
    
    func setupAllChats(onFetch onFetch: ([Chat]) -> Void, onNewMessage: (ChatMessage) -> Void, onChatDelete: (String) -> Void, onError: (NSError) -> Void) {
        MessagesManager.sharedInstance.getMessagesWithMe { (messages, error) in
            if error != nil {
                onError(error!)
            } else {                
                /*let chats = self.makeChats(messages!)
                onFetch(chats)
                
                BackendlessMessaging().subscribe({ (newMessages, error) in
                    if error != nil {
                        onError(error!)
                    } else {
                        for newMessage in newMessages! {
                            if newMessage.isChatDeleteNotification {
                                //onChatDelete(newMessage.publisherId)
                            } else if !newMessage.isMessageDeleteNotification {
                                MessagesManager().getMessage(byId: newMessage.messagesDBId!, completion: { (fetchedMessage, error) in
                                    if error != nil {
                                        onError(error!)
                                    } else {
                                        onNewMessage(fetchedMessage!)
                                    }
                                })
                            }
                        }
                    }
                })*/
            }
        }
    }
    
    func setupChatWithUser(interlocator: Users, onFetch: ([Message]) -> Void, onNewMessage: (Message) -> Void, onMessageDeleted: (String) -> Void, onError: (NSError) -> Void) {
        /*MessagesManager().getMessagesWithMeAndInterlocator(interlocator) { (messages, error) in
            if error != nil {
                onError(error!)
            } else {
                onFetch(messages!)
                
                BackendlessMessaging().subscribe(interlocator, responce: { (newMessages, error) in
                    if error != nil {
                        onError(error!)
                    } else {
                        for newMessage in newMessages! {
                            if newMessage.isMessageDeleteNotification {
                                onMessageDeleted(newMessage.messagesDBId!)
                            } else if !newMessage.isChatDeleteNotification { // this one is not handling there
                                MessagesManager().getMessage(byId: newMessage.messagesDBId!, completion: { (fetchedMessage, error) in
                                    if error != nil {
                                        onError(error!)
                                    } else {
                                        onNewMessage(fetchedMessage!)
                                    }
                                })
                            }
                        }
                    }
                })
            }
        }*/
    }
    
    func deleteMessage(msg: ChatMessage, interlocutor: Users, completion: (Bool, NSError?) -> Void) {
        msg.delete { (success) in
            if success {
                BackendlessMessaging().notifyMessageDeleted(msg, toUser: interlocutor, completion: { (success, error) in
                    completion(success, error)
                })
            } else {
                completion(false, ErrorHelper().getNSError(withCode: 0, withMessage: "failed to delete message"))
            }
        }
    }
    
    func deleteChat(chat: Chat, completion: (Bool, NSError?) -> Void) {
        //MessagesManager().deleteMessages(chat.messages)
        /*BackendlessMessaging().notifyChatDeleted(withUserId: chat.interlocutor.objectId) { (success, error) in
            completion(success, error)
        }*/
    }
    
    private func makeChats(messages: [Message]) -> [Chat] {
        let myId = UserManager().currentUser().objectId
        var chatPairs = [String: [Message]]()
        for message in messages {
            //let interlocutorId = message.senderId == myId ? message.recipentId : message.senderId
            
            /*if chatPairs[interlocutorId!] != nil {
                chatPairs[interlocutorId!]?.append(message)
            } else {
                chatPairs[interlocutorId!] = [message]
            }*/
        }
        
        var chats = [Chat]()
        for (interlocutor, messages) in chatPairs {
            chats.append(Chat(interlocutor: UserManager().getUserByIdSync(interlocutor)!, messages: messages))
        }
        
        return chats
    }
}
