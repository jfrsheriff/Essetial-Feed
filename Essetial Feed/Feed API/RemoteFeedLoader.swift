//
//  RemoteFeedLoader.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 08/09/22.
//

import Foundation

public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void )
}

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
                    
                    if response.statusCode == 200 , let root = try? JSONDecoder().decode(Root.self, from: data){
                        completion(.success(root.items))
                    }else{
                        completion(.failure(.invalidData))
                    }
                case .failure(_) :
                    completion(.failure(.connectivity))
                    
            }
        }
    }
}


private struct Root : Decodable {
    let items : [FeedItem]
}
