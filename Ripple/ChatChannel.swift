//
//  ChatChannel.swift
//  Ripple
//
//  Created by Evgeny Ivanov on 28.12.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class ChatChannel: BackendlessEntity {

    var messages: [ChatMessage]?
    var lastMessage: ChatMessage?
    var users: [BackendlessUser]?
    
    static func loadAllChannels(forUser: BackendlessUser, completion:([ChatChannel]) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "users.objectId in ('" + forUser.objectId + "')"
        let queryOptions = QueryOptions()
        queryOptions.related = ["users", "users.picture", "messages", "lastMessage"]
        query.queryOptions = queryOptions
        
        ChatChannel().dataStore().find(query, response: { (collection) in
            let channels = collection.data as? [ChatChannel] ?? [ChatChannel]()
            completion(channels)
        }, error:  { (fault) in
            completion([ChatChannel]())
        })
    }
    
    func userAddressee() -> BackendlessUser? {
        guard let members = users else {
            return nil
        }
        
        for user in members {
            if user.objectId != UserManager().currentUser().objectId {
                return user
            }
        }
        
        return nil
    }
    
    func channelForUser(user: Users, completion:(ChatChannel) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "users.objectId = '" + user.objectId + "'"
        let queryOptions = QueryOptions()
        queryOptions.related = ["users"]
        query.queryOptions = queryOptions
        
        ChatChannel().dataStore().find(query, response: { (collection) in
            let channels = collection.data as? [ChatChannel] ?? [ChatChannel]()
            
            for channel in channels {
                for user in channel.users! {
                    if user.objectId == UserManager().currentUser().objectId {
                        completion(channel)
                        return
                    }
                }
            }
            
            let channel = ChatChannel()
            completion(channel)
        }, error:  { (fault) in
            let channel = ChatChannel()
            completion(channel)
        })
    }
}
