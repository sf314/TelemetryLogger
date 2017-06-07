//
//  TelemetryLoggerTests.swift
//  TelemetryLoggerTests
//
//  Created by Stephen Flores on 6/4/17.
//  Copyright © 2017 Stephen Flores. All rights reserved.
//

import XCTest
@testable import TelemetryLogger

class TelemetryLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Telemetry_update() {
        var tel = Telemetry()
        tel.shouldSave = false
        
        // No spaces
        var result = tel.update(["TESTTLM", "0.81", "-0.87", "-0.95", "0.89\r"])
        XCTAssert(result)
        XCTAssert(tel.data[0] == 0.81)
        XCTAssert(tel.data[3] == 0.89)
        
        // With empty bits
        result = tel.update(["TELEM", "31.2", "", "12.1"])
        XCTAssert(!result)
        XCTAssert(tel.data[0] == 31.2)
        XCTAssert(tel.data[1] == 0.0)
    }
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
