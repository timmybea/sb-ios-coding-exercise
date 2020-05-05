//
//  Recommendation.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

struct Recommendation: Codable {
    var imageURL: String
    var title: String
    var tagline: String
    var rating: Float
    var isReleased: Bool
    
    enum RecommendationKey: String, CodingKey {
        case imageURL = "image"
        case title
        case tagline
        case rating
        case isReleased = "is_released"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecommendationKey.self)
        
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.title = try container.decode(String.self, forKey: .title)
        self.tagline = try container.decode(String.self, forKey: .tagline)
        self.isReleased = try container.decode(Bool.self, forKey: .isReleased)
        
        // rating can have nil value in the json. Provide default value for decode failure
        self.rating = (try? container.decode(Float.self, forKey: .rating)) ?? 0.0
    }
    
}
