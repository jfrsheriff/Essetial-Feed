//
//  RemoteFeedLoaderTests.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 05/09/22.
//

import XCTest
import CI

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl(){
        let (_,client) = makeSUT()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsDataFromUrl(){
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
