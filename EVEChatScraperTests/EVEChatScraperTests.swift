//
//  EVEChatScraperTests.swift
//  EVEChatScraperTests
//
//  Created by Mike Muszynski on 2/14/16.
//  Copyright © 2016 Mike Muszynski. All rights reserved.
//

import XCTest
@testable import EVEChatScraper

class EVEChatScraperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindLogFiles() {
        let testURL = NSURL(string: "/Users/mike/Cocoa/Tests/EVE Logs/Chatlogs".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!

    }
    
}
