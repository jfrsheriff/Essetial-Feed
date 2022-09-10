//
//  FeedItem.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import Foundation

public struct FeedItem : Equatable {
    public let id : UUID
    public let description : String?
    public let location : String?
    public let imageURL : URL
    
    public init(id : UUID,
                description : String? = nil ,
                location : String? = nil,
                imageURL : URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
