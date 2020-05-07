//
//  Recommendation.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class Recommendation: NSObject, NSCoding, Codable {
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
    
    required init?(coder: NSCoder) {
        self.imageURL = coder.decodeObject(forKey: RecommendationKey.imageURL.rawValue) as? String ?? ""
        self.title = coder.decodeObject(forKey: RecommendationKey.title.rawValue) as? String ?? ""
        self.tagline = coder.decodeObject(forKey: RecommendationKey.tagline.rawValue) as? String ?? ""
        self.rating = coder.decodeObject(forKey: RecommendationKey.rating.rawValue) as? Float ?? 0.0
        self.isReleased = coder.decodeObject(forKey: RecommendationKey.isReleased.rawValue) as? Bool ?? false
     }
     
     func encode(with coder: NSCoder) {
        coder.encode(self.imageURL, forKey: RecommendationKey.imageURL.rawValue)
        coder.encode(self.title, forKey: RecommendationKey.title.rawValue)
        coder.encode(self.tagline, forKey: RecommendationKey.tagline.rawValue)
        coder.encode(self.isReleased, forKey: RecommendationKey.isReleased.rawValue)
     }
    
}
