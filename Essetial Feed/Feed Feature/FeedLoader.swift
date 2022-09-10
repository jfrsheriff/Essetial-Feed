//
//  FeedLoader.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader{
    func load(completion : @escaping (LoadFeedResult) -> Void )
}
