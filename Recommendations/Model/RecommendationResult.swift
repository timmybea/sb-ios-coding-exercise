//
//  RecommendationResult.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class RecommendationResult: NSObject, NSCoding, Codable {
    
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
    
    required init?(coder: NSCoder) {
        self.titles = coder.decodeObject(forKey: RecommendationResultKey.titles.rawValue) as? [Recommendation] ?? []
        self.skipped = coder.decodeObject(forKey: RecommendationResultKey.skipped.rawValue) as? [String] ?? []
        self.titlesOwned = coder.decodeObject(forKey: RecommendationResultKey.titlesOwned.rawValue) as? [String] ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.titles, forKey: RecommendationResultKey.titles.rawValue)
        coder.encode(self.skipped, forKey: RecommendationResultKey.skipped.rawValue)
        coder.encode(self.titlesOwned, forKey: RecommendationResultKey.titlesOwned.rawValue)
    }
    
}
