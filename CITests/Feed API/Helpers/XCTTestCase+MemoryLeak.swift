//
//  XCTTestCase+MemoryLeak.swift
//  CITests
//
//  Created by Jaffer Sheriff U on 14/09/22.
//

import XCTest


extension XCTestCase{
    func trackForMemoryLeak ( _ instance : AnyObject , file: StaticString = #filePath, line: UInt = #line){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance Should Have Been Deallocation . Potential Memory Leak", file: file, line: line)
        }
    }
}
