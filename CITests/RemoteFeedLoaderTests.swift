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
        
        self.expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut,client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            self.expect(sut, toCompleteWithResult: .failure(.invalidData) ) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson(){
        let (sut,client) = makeSUT()
        self.expect(sut, toCompleteWithResult: .failure(.invalidData) ) {
            let invalidJsonData = Data.init("Invalid Json".utf8)
            client.complete(withStatusCode: 200, data: invalidJsonData)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList(){
        let (sut,client) = makeSUT()
        
        self.expect(sut,
                    toCompleteWithResult: .success([])) {
            let emptyJsonList = Data.init("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJsonList)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonList(){
        let (sut,client) = makeSUT()
        let item1 = FeedItem(imageURL: URL(string: "https:a-url.com")!)
        let item1Json = [
            "id" : item1.id.uuidString,
            "image" : item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(description: "A Description",
                             location: "A Location",
                             imageURL: URL(string: "https:b-url.com")!)
        let item2Json = [
            "id" : item2.id.uuidString,
            "description" : item2.description,
            "location" : item2.location,
            "image" : item2.imageURL.absoluteString
        ]
                
        let itemsJson = [
            "items" : [item1Json,item2Json]
        ]
        
        expect(sut,
               toCompleteWithResult: .success([item1,item2])) {
            let jsonData = try! JSONSerialization.data(withJSONObject: itemsJson)
            client.complete(withStatusCode: 200,
                            data: jsonData)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url : URL = URL(string: "www.a-given-url.com")! ) -> (sut : RemoteFeedLoader, client : HTTPClientSpy ) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut , client)
    }
    
    private func expect(_ sut : RemoteFeedLoader ,
                        toCompleteWithResult result: RemoteFeedLoader.Result ,
                        when action : () -> Void ,
                        file: StaticString = #filePath,
                        line: UInt = #line ){
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load(){
            capturedResults.append($0)
        }
        action()
        XCTAssertEqual(capturedResults, [result] ,file: file,line: line)
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
