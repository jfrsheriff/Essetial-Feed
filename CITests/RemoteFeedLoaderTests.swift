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
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromUrl(){
        let url = URL(string: "www.a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in}
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsDataFromUrlTwice(){
        let url = URL(string: "www.a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in}
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedUrls, [url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSUT()
        
        self.expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut,client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            self.expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson(){
        let (sut,client) = makeSUT()
        self.expect(sut, toCompleteWithError: .invalidData) {
            let invalidJsonData = Data.init("Invalid Json".utf8)
            client.complete(withStatusCode: 200, data: invalidJsonData)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url : URL = URL(string: "www.a-given-url.com")! ) -> (sut : RemoteFeedLoader, client : HTTPClientSpy ) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut , client)
    }
    
    private func expect(_ sut : RemoteFeedLoader ,
                        toCompleteWithError error: RemoteFeedLoader.Error ,
                        when action : () -> Void ,
                        file: StaticString = #filePath,
                        line: UInt = #line ){
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load(){
            capturedResults.append($0)
        }
        action()
        XCTAssertEqual(capturedResults, [.failure(error)] ,file: file,line: line)
    }
    
    
    private class HTTPClientSpy : HTTPClient{
        
        private var messages : [(url : URL , completion : (HTTPClientResult) -> Void )] = []
        
        var requestedUrls : [URL] {
            messages.map{ $0.url }
        }
        
        func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void ) {
            messages.append((url,completion))
        }
        
        func complete(with error : Error, at index : Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code : Int, data : Data = Data(), at index : Int = 0){
            let status = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success(data,status))
        }
    }
    
}
