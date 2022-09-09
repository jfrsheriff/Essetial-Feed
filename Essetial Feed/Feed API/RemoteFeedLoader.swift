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
    
    public enum Error {
        case connectivity
        case invalidData
    }
    
    private let url : URL
    private let client : HTTPClient
    
    public init(url : URL , client : HTTPClient){
        self.url = url
        self.client = client
    }
    
    public func load(completion : @escaping (Error) -> Void ){
        client.get(from: url){ clientResult in
            
            switch clientResult{
                case .success(let data, let response):
                    completion(.invalidData)
                case .failure(_) :
                    completion(.connectivity)
            }
        }
    }
}


