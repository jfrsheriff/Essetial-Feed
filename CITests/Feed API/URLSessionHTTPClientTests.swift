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
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    
    func test_getFromUrl_resumeDataTaskWithURL(){
        let url = URL(string: "https://a-url.com")!
         
        let session = URLSessionSpy()
        let spyTask = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: spyTask)
        let sut = URLSessionHTTPClient(session)
        
        sut.get(from: url)
        
        XCTAssertEqual(spyTask.resumeCallCount, 1)
    }
    
    
    
    
    private class URLSessionSpy : URLSession{

        var resumeTask : [URL : URLSessionDataTask] = [:]
        
        func stub(url : URL , task: URLSessionDataTask) {
            resumeTask[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return resumeTask[url] ?? FakeURLSessionDataTask()
        }
    }
    
    
    private class FakeURLSessionDataTask : URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy : URLSessionDataTask {
        var resumeCallCount : Int = 0
        override func resume() {
            resumeCallCount += 1
        }
    }

}
