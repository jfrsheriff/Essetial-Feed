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
    
    public init( _ session : URLSession = .shared) {
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
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromUrl_performGetRequestFromUrl() {
        
        let url = URL(string: "https://a-url.com")!
        let exp = expectation(description: "Wait For Completion")
        
        URLProtocolStub.obseveRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in}
        wait(for: [exp], timeout: 1)
    }
    
    
    func test_getFromUrl_failsOnRequestError(){
        
        let url = URL(string: "https://a-url.com")!
        let error = NSError(domain: "A Error", code: 1)
                
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let expectation = expectation(description: "Wait For Completion")
        
        makeSUT().get(from: url){ result in
            switch result{
                case let .failure(receivedError as NSError) :
                    XCTAssertEqual(receivedError.domain, error.domain)
                    XCTAssertEqual(receivedError.code, error.code)
                default :
                    XCTFail("Expected failure with error \(error), but got \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func trackForMemoryLeak ( _ instance : AnyObject , file: StaticString = #filePath, line: UInt = #line){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance Should Have Been Deallocation . Potential Memory Leak", file: file, line: line)
        }
    }
    
    private class URLProtocolStub : URLProtocol {
        
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest) -> Void)?
        
        private struct Stub {
            let data : Data?
            let response : URLResponse?
            let error : Error?
        }
        
        static func startInterceptingRequests(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func obseveRequests(observer : @escaping (URLRequest) -> Void ) {
            requestObserver = observer
        }
        
        static func stub( data : Data? , response : URLResponse?, error : Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let data = URLProtocolStub.stub?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
    
}
