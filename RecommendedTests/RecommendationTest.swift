//
//  RecommendationTest.swift
//  RecommendedTests
//
//  Created by Tim Beals on 2020-06-17.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import XCTest

//@testable import Recommended
class RecommendationTest: XCTestCase {

    var data: Data!
    var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        data = JSONData(fileName: "recommendation").data!
        decoder = JSONDecoder()
    }
    
    
    override func tearDown() {
        data = nil
        decoder = nil
        
        super.tearDown()
    }

    func test_initialize_from_decoder() {
        
        guard let recommendation = try? decoder.decode(Recommendation.self, from: data) else {
            XCTFail("Failure: recommendation not initialized")
            return
        }
            
        XCTAssertNotNil(recommendation)
        XCTAssertEqual(recommendation.title, "Marvel's Thor: Metal Gods")
        XCTAssertEqual(recommendation.tagline, "test tagline")
        XCTAssertTrue(recommendation.isReleased)
        XCTAssertEqual(recommendation.rating, 4.78)
        XCTAssertEqual(recommendation.imageURL, "https://test/path/image.png")
        
    }

}
