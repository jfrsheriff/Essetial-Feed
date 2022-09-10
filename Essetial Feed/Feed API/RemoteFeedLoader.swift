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
