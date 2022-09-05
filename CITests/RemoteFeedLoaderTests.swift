//
//  RemoteFeedLoaderTests.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import XCTest


class RemoteFeedLoader {
    let client : HTTPClient
    let url : URL
    
    init(url : URL , client : HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(){
        client.get(from: url)
    }
}

protocol HTTPClient{
    func get(from url : URL)
}


class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl(){
        let (_,client) = makeSUT()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_init_requestDataFromUrl(){
        let url = URL(string: "www.a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load()
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(url : URL = URL(string: "www.a-given-url.com")! ) -> (sut : RemoteFeedLoader, client : HTTPClientSpy ) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut , client)
    }
    
    
    
    private class HTTPClientSpy : HTTPClient{
        var requestedUrl : URL?
        
        func get(from url : URL){
            self.requestedUrl = url
        }
    }
}
