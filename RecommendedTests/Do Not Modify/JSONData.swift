//
//  JSONData.swift
//  RecommendedTests
//
//  Created by Tim Beals on 2020-06-16.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class JSONData {
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    private let fileName: String
    
    var json: Any? {
        guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") else {
            return nil
        }
        
        if let jsonData = NSData(contentsOfFile: path) {
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                return jsonResult
            }
            catch {
                assertionFailure("Failed to build json for \(path) error: \(error)")
            }
        }
        
        return nil
    }


    var data: Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self.json!, options: JSONSerialization.WritingOptions(rawValue: 0))
            return data
        }
        catch {
            assertionFailure("Failed to build \(String(describing: self.json)) response data: \(error)")
            return nil
        }
    }

}
