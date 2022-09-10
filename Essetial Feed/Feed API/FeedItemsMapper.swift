//
//  FeedItemsMapper.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 10/09/22.
//

import Foundation

internal struct FeedItemsMapper{
    
    private struct Root : Decodable {
        let items : [Item]
    }
    
    private struct Item : Decodable {
        let id : UUID
        let description : String?
        let location : String?
        let image : URL
        
        var feedItem : FeedItem{
            FeedItem(id: id,
                     description: description,
                     location: location,
                     imageURL: image)
        }
    }
    
    private static var OK_200 : Int{ 200 }
    
    internal static func map(data : Data , response : HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.feedItem}
    }
    
}
