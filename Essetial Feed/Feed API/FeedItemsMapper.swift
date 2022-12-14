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
        
        var feeds : [FeedItem] {
            items.map{$0.feedItem}
        }
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
    
    
    internal static func mapDataAndResponseToResult ( _ data : Data , _ response : HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200 , let root = try? JSONDecoder().decode(Root.self, from: data) else{
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feeds)
       
    }
    
}
