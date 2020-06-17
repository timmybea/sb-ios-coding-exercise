//
//  MockEndPoint.swift
//  RecommendedTests
//
//  Created by Tim Beals on 2020-06-17.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class MockEndpoint: URLProtocol {

    open class var url: URL {
        preconditionFailure("Override MockEndpoint.url in your subclass.")
    }

    open class var request: URLRequest {
        return URLRequest(url: url)
    }

    open var response: URLResponse? {
        return nil
    }

    open var error: Swift.Error? {
        return nil
    }

    open var data: Data? {
        return nil
    }

    var passthrough: Bool {
        return false
    }

    open var passthroughConfiguration: URLSessionConfiguration {
        return URLSessionConfiguration.default
    }

    open func performPassthrough() {

        let session = URLSession(configuration: passthroughConfiguration)

        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in

            guard error == nil else {
                self.client?.urlProtocol(self, didFailWithError: error!)
                return
            }

            self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)

            if let _ = data {
                self.client?.urlProtocol(self, didLoad: data!)
            }

            self.client?.urlProtocolDidFinishLoading(self)
        }.resume()
    }
}

extension MockEndpoint {
    
    override class func canInit(with request: URLRequest) -> Bool {

        // URL
        guard let endpointUrl = self.request.url, let requestUrl = request.url, endpointUrl == requestUrl else { return false}

        // HTTP Method
        guard let endpointHttpMethod = self.request.httpMethod, let requestHttpMethod = request.httpMethod, endpointHttpMethod == requestHttpMethod else { return false }

        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {

        if passthrough {
            performPassthrough()
            return
        }

        if let _ = error {
            client?.urlProtocol(self, didFailWithError: error!)
            return
        }

        guard let response = self.response else {
            preconditionFailure("A URLResponse was not defined.  Override MockEndpoint.response in your subclass.")
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let _ = data {
            client?.urlProtocol(self, didLoad: data!)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {    }
}
