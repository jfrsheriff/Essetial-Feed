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
    
    private struct UexpectedValuesRepresentation : Error {}
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.failure(UexpectedValuesRepresentation()))
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
        
        let url = anyUrl()
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
        let requestError = NSError(domain: "A Error", code: 1)
        let receivedError = resultErrorFor(data: nil, reponse: nil, error: requestError) as? NSError
        XCTAssertEqual(receivedError?.domain , requestError.domain)
    }
    
    
    func test_getFromUrl_failsOnAllInvalidRepresentationCases(){
        XCTAssertNotNil(resultErrorFor(data: nil, reponse: nil, error: nil) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: nil, reponse: nonHTTPUrlResponse() , error: nil) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: nil, reponse: anyHTTPUrlResponse() , error: nil) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: anyData(), reponse: nil , error: nil) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: anyData(), reponse: nil , error: anyNSError()) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: nil, reponse: nonHTTPUrlResponse() , error: anyNSError()) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: nil, reponse: anyHTTPUrlResponse(), error: anyNSError()) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: anyData(), reponse: nonHTTPUrlResponse() , error: anyNSError()) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: anyData(), reponse: anyHTTPUrlResponse(), error: anyNSError()) as? NSError)
        XCTAssertNotNil(resultErrorFor(data: anyData(), reponse: nonHTTPUrlResponse() , error: nil) as? NSError)
    }
    
    private func anyData() -> Data{
        Data("Invalid Json".utf8)
    }
    
    private func anyNSError() -> NSError{
        NSError(domain: "An Error", code: 0)
    }
    
    private func nonHTTPUrlResponse() -> URLResponse{
        URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    private func anyHTTPUrlResponse() -> HTTPURLResponse{
        HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    // MARK: - Helpers
    
    private func resultErrorFor(data : Data?, reponse : URLResponse? , error : Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: reponse, error: error)

        var receivedError : Error? = nil
        let expectation = expectation(description: "Wait For Completion")
        let sut = makeSUT(file:file,line:line)
        
        sut.get(from: anyUrl()){ result in
            switch result{
                case let .failure(error):
                    receivedError = error
                    break
                default :
                    XCTFail("Expected failure , got \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        return receivedError
    }
    
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    
    private func anyUrl() -> URL {
        return URL(string: "https://a-url.com")!
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
