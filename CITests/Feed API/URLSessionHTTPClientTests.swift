//
//  URLSessionHTTPClientTests.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 12/09/22.
//

import XCTest
import CI

public class URLSessionHTTPClient {
    
    private let session : URLSession
    
    public init( _ session : URLSession) {
        self.session = session
    }
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
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
        
        sut.get(from: url){_ in}
        
        XCTAssertEqual(spyTask.resumeCallCount, 1)
    }
    
    func test_getFromUrl_failsOnRequestError(){
        let url = URL(string: "https://a-url.com")!
        let error = NSError(domain: "A Error", code: 1)
         
        let session = URLSessionSpy()
        let spyTask = URLSessionDataTaskSpy()
        
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session)
        
        let expectation = expectation(description: "Wait For Completion")
        
        sut.get(from: url){ result in
            switch result{
                case let .failure(receivedError as NSError) :
                    XCTAssertEqual(receivedError, error)
                default :
                    XCTFail("Expected failure with error \(error), but got \(result)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    
    
    
    private class URLSessionSpy : URLSession{

        private var stubs : [URL : Stub] = [:]
        
        private struct Stub {
            let task : URLSessionDataTask
            let error : NSError?
        }
        
        func stub(url : URL , task: URLSessionDataTask = FakeURLSessionDataTask() , error : NSError? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
         
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub =  stubs[url] else {
                fatalError("Could Not Find Stub for \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
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
