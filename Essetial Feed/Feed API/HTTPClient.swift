//
//  HTTPClient.swift
//  Essetial Feed
//
//  Created by Jaffer Sheriff U on 10/09/22.
//

import Foundation


public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void )
}

