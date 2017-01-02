//
//  Message.swift
//  Ripple
//
//  Created by nikitaivanov on 16/12/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import Foundation

class ChatMessage: BackendlessEntity {
    var message: String?
    var ownerId: String?
    
    static func messagesIn(channel: ChatChannel, completion: ([ChatMessage]) -> Void) {
        let query = BackendlessDataQuery()
        query.whereClause = "ChatChannel[messages].objectId = '" + channel.objectId + "'"
        let queryOptions = QueryOptions()
        queryOptions.sortBy(["created"])
        query.queryOptions = queryOptions
        
        ChatMessage().dataStore().find(query, response: { (collection) in
            let messages = collection.data as? [ChatMessage] ?? [ChatMessage]()
            completion(messages)
        }, error:  { (fault) in
            completion([ChatMessage]())
        })
    }
    
}
