//
//  FeedLoader.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import Foundation

public enum LoadFeedResult<Error : Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader{
    associatedtype Error: Swift.Error
    func load(completion : @escaping (LoadFeedResult<Error>) -> Void )
}
