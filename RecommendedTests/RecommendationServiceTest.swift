//
//  RecommendationServiceTest.swift
//  RecommendedTests
//
//  Created by Tim Beals on 2020-06-17.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import XCTest

class RecommendationServiceTest: XCTestCase {

    func test_error_received() {

        enum TestError: Error {
            case expected
        }
        
        class TestEndPoint: MockEndpoint {
            override class var url: URL {
                return URL(string: "https://www.address-does-not-matter.com")!
            }
            
            override var error: Error? {
                return TestError.expected
            }
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(TestEndPoint.self, at: 0)
        
        let session = URLSession(configuration: config)
        
        let asyncExpectation = expectation(description: "entering recommendation service")
        
        RecommendationService().getRecommendedTitles(session: session) { (result) in
            defer { asyncExpectation.fulfill() }
            
            switch result {
            case .success(_):
                XCTFail("get recommended titles should not succeed")
            case .failure(let error):
                
                guard let error = error as? TestError else {
                    XCTFail("Error should be TestError type")
                    return
                }
                
                XCTAssertEqual(error, TestError.expected)
            }
            
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_parsing_error() {
        
        class TestEndPoint: MockEndpoint {
            
            override class var url: URL {
                return URL(string: "https://www.address-does-not-matter.com")!
            }
            
            override var response: URLResponse? {
                return HTTPURLResponse(url: TestEndPoint.url, statusCode: 200, httpVersion: "1.0", headerFields: nil)
            }
            
            //Incorrect data type: Recommendation. Should be RecommendationResult
            override var data: Data? {
                return JSONData(fileName: "recommendation").data!
            }
            
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(TestEndPoint.self, at: 0)
        
        let session = URLSession(configuration: config)
        
        let asyncExpectation = expectation(description: "entering recommendation service")
        
        RecommendationService().getRecommendedTitles(session: session) { (result) in
            defer { asyncExpectation.fulfill() }
            
            switch result {
            case .success(_):
                XCTFail("get recommended titles should not succeed")
            case .failure(let error):
                    
                guard let error = error as? BaseWebService.WebServiceError else {
                    XCTFail("Error should be WebServiceError type")
                    return
                }

                XCTAssertEqual(error, BaseWebService.WebServiceError.parsing)
            }
            
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func test_status_code_error() {
        
        class TestEndPoint: MockEndpoint {
            
            override class var url: URL {
                return URL(string: "https://www.address-does-not-matter.com")!
            }
            
            // valid status code is 200-300.
            override var response: URLResponse? {
                return HTTPURLResponse(url: TestEndPoint.url, statusCode: 400, httpVersion: "1.0", headerFields: nil)
            }
            
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(TestEndPoint.self, at: 0)
        
        let session = URLSession(configuration: config)
        
        let asyncExpectation = expectation(description: "entering recommendation service")
        
        RecommendationService().getRecommendedTitles(session: session) { (result) in
            defer { asyncExpectation.fulfill() }
            
            switch result {
            case .success(_):
                XCTFail("get recommended titles should not succeed")
            case .failure(let error):
                
                guard let error = error as? BaseWebService.WebServiceError else {
                    XCTFail("Error should be WebServiceError type")
                    return
                }
                
                XCTAssertEqual(error, BaseWebService.WebServiceError.statusCode)
            }
            
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_success_recommendation() {
        
        class TestEndPoint: MockEndpoint {
            
            override class var url: URL {
                return URL(string: "https://www.address-does-not-matter.com")!
            }
            
            override var response: URLResponse? {
                return HTTPURLResponse(url: TestEndPoint.url, statusCode: 200, httpVersion: "1.0", headerFields: nil)
            }
            
            override var data: Data? {
                return JSONData(fileName: "ratings").data!
            }
            
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(TestEndPoint.self, at: 0)
        
        let session = URLSession(configuration: config)
        
        let asyncExpectation = expectation(description: "entering recommendation service")
        
        RecommendationService().getRecommendedTitles(session: session) { (result) in
            defer { asyncExpectation.fulfill() }
            
            switch result {
            case .success(let recommendation):
                
                XCTAssertNotNil(recommendation)
                
                XCTAssertEqual(recommendation.titles.count, 87)
                XCTAssertEqual(recommendation.titles[0].title, "Marvel's Thor: Metal Gods")
                XCTAssertEqual(recommendation.titles[0].tagline, "Thor and Loki embark on a cosmic odyssey to stop the return of an ancient evil.")
                XCTAssertTrue(recommendation.titles[0].isReleased)
                XCTAssertEqual(recommendation.titles[0].rating, 4.78)
                XCTAssertEqual(recommendation.titles[0].imageURL, "https://res.cloudinary.com/serial-box/image/upload/w_319,h_414,c_fill/v1586555748/uploads/production/serial/cover_tall-bac373c6-2788-47bd-a020-32ed3815712c.png")
                
                XCTAssertEqual(recommendation.skipped.count, 11)
                XCTAssertEqual(recommendation.skipped[0], "ReMade")
                
                XCTAssertEqual(recommendation.titlesOwned.count, 4)
                XCTAssertEqual(recommendation.titlesOwned[0], "Marvel's Thor: Metal Gods")
                
            case .failure(_):
                XCTFail("get recommended should not fail")
            }
            
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
}
