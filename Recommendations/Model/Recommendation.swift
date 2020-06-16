//
//  Recommendation.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class Recommendation: NSObject, Codable {
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecommendationKey.self)
        
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.title = try container.decode(String.self, forKey: .title)
        self.tagline = try container.decode(String.self, forKey: .tagline)
        self.isReleased = try container.decode(Bool.self, forKey: .isReleased)
        
        // rating can have nil value in the json. Provide default value for decode failure
        self.rating = (try? container.decode(Float.self, forKey: .rating)) ?? 0.0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RecommendationKey.self)
        
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(title, forKey: .title)
        try container.encode(tagline, forKey: .tagline)
        try container.encode(isReleased, forKey: .isReleased)
        try container.encode(rating, forKey: .rating)
        
    }
        
}
