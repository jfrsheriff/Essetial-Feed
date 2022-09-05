//
//  RemoteFeedLoaderTests.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import XCTest


class RemoteFeedLoader {
    let client : HTTPClient
    
    init(client : HTTPClient){
        self.client = client
    }
    
    func load(){
        client.get(from: URL(string: "https://www.google.com")!)
    }
}

protocol HTTPClient{
    func get(from url : URL)
}

class HTTPClientSpy : HTTPClient{
    var requestedUrl : URL?
    
    func get(from url : URL){
        self.requestedUrl = url
    }
}


class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl(){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_init_requestDataFromUrl(){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        XCTAssertNotNil(client.requestedUrl)
    }
    
}
