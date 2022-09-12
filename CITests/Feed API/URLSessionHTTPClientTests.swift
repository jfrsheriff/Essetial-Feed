//
//  URLSessionHTTPClientTests.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 12/09/22.
//

import XCTest

public class URLSessionHTTPClient {
    
    private let session : URLSession
    
    public init( _ session : URLSession) {
        self.session = session
    }
    
    func get(from url : URL){
        session.dataTask(with: url) { _, _, _ in
            
        }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromUrl_createDataTaskWithURL(){
        let url = URL(string: "https://a-url.com")!
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    
    
    private class URLSessionSpy : URLSession{
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    
    private class FakeURLSessionDataTask : URLSessionDataTask {}

}
