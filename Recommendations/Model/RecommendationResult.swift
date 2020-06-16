//
//  RecommendationResult.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class RecommendationResult: NSObject, Codable {
    
    var titles: [Recommendation]
    var skipped: [String]
    var titlesOwned: [String]
    
    enum RecommendationResultKey: String, CodingKey {
        case titles
        case skipped
        case titlesOwned = "titles_owned"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecommendationResultKey.self)
        
        self.titles = try container.decode([Recommendation].self, forKey: .titles)
        self.skipped = try container.decode([String].self, forKey: .skipped)
        self.titlesOwned = try container.decode([String].self, forKey: .titlesOwned)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RecommendationResultKey.self)
           
        try container.encode(titles, forKey: .titles)
        try container.encode(skipped, forKey: .skipped)
        try container.encode(titlesOwned, forKey: .titlesOwned)
    }
    
}
