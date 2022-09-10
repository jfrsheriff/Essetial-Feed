//
//  RemoteFeedLoader.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 08/09/22.
//

import Foundation

public final class RemoteFeedLoader {
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result : Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    private let url : URL
    private let client : HTTPClient
    
    public init(url : URL , client : HTTPClient){
        self.url = url
        self.client = client
    }
    
    public func load(completion : @escaping (Result) -> Void ){
        client.get(from: url){ clientResult in
            
            switch clientResult{
                case .success(let data,let response):
                    do {
                        let items = try FeedItemsMapper.map(data: data, response: response)
                        completion(.success(items))
                    }catch{
                        completion(.failure(.invalidData))
                    }
                case .failure(_) :
                    completion(.failure(.connectivity))
                    
            }
        }
    }
}


private struct FeedItemsMapper{
    
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
    
    static func map(data : Data , response : HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.feedItem}
    }
    
}
