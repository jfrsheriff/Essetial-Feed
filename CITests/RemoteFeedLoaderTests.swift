//
//  RemoteFeedLoaderTests.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import XCTest


class RemoteFeedLoader {
}

class HTTPClient{
    var requestedUrl : URL?
}


class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl(){
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedUrl)
        
    }
    
}
