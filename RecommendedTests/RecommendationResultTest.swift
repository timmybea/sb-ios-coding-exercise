//
//  RecommendationResultTest.swift
//  RecommendedTests
//
//  Created by Tim Beals on 2020-06-16.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import XCTest

class RecommendationResultTest: XCTestCase {
    
    var data: Data!
    var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        data = JSONData(fileName: "ratings").data!
        decoder = JSONDecoder()
    }
    
    
    override func tearDown() {
        data = nil
        decoder = nil
        
        super.tearDown()
    }
    
    func test_initialize_from_decoder() throws {
        guard let result = try? decoder.decode(RecommendationResult.self, from: data) else {
            XCTFail("Failure: recommendation not initialized")
            return
        }
            
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result.titles.count, 87)
        XCTAssertEqual(result.titles[0].title, "Marvel's Thor: Metal Gods")
        XCTAssertEqual(result.titles[0].tagline, "Thor and Loki embark on a cosmic odyssey to stop the return of an ancient evil.")
        XCTAssertTrue(result.titles[0].isReleased)
        XCTAssertEqual(result.titles[0].rating, 4.78)
        XCTAssertEqual(result.titles[0].imageURL, "https://res.cloudinary.com/serial-box/image/upload/w_319,h_414,c_fill/v1586555748/uploads/production/serial/cover_tall-bac373c6-2788-47bd-a020-32ed3815712c.png")
        
        XCTAssertEqual(result.skipped.count, 11)
        XCTAssertEqual(result.skipped[0], "ReMade")
        
        XCTAssertEqual(result.titlesOwned.count, 4)
        XCTAssertEqual(result.titlesOwned[0], "Marvel's Thor: Metal Gods")

    }
    
}
