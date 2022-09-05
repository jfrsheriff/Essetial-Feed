//
//  FeedLoader.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader{
    func load(completionn : @escaping (LoadFeedResult) -> Void )
}
