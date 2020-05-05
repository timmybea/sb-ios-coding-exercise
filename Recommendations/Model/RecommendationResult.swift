//
//  RecommendationResult.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

struct RecommendationResult: Codable {
    var titles: [Recommendation]
    var skipped: [String]
    var titlesOwned: [String]
    
    enum RecommendationResultKey: String, CodingKey {
        case titles
        case skipped
        case titlesOwned = "titles_owned"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecommendationResultKey.self)
        
        self.titles = try container.decode([Recommendation].self, forKey: .titles)
        self.skipped = try container.decode([String].self, forKey: .skipped)
        self.titlesOwned = try container.decode([String].self, forKey: .titlesOwned)
    }
}
