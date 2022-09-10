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
    
    public typealias Result = LoadFeedResult<Error>
    
    private let url : URL
    private let client : HTTPClient
    
    public init(url : URL , client : HTTPClient){
        self.url = url
        self.client = client
    }
    
    public func load(completion : @escaping (Result) -> Void ){
        client.get(from: url){ [weak self] result in
            guard let _ = self else { return }
            switch result{
                case .success(let data,let response):
                    completion(FeedItemsMapper.mapDataAndResponseToResult(data, response))
                case .failure(_) :
                    completion(.failure( Error.connectivity ))
                    
            }
        }
    }
    
}
