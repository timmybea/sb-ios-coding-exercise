//
//  RecommendationViewModel.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-06.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

protocol RecommendationViewModelDelegate {
    func provideImage(for recommendationViewModel: RecommendationViewModel, completion: @escaping(UIImage?)->())
}

//MARK: RecommendationViewModel
class RecommendationViewModel {
    
    private var recommendation: Recommendation
    
    init(_ recommendation: Recommendation) {
        self.recommendation = recommendation
    }
    
    var delegate: RecommendationViewModelDelegate?
    
    var titleLabel: String {
        return self.recommendation.title
    }
    
    var taglineLabel: String {
        return self.recommendation.tagline
    }
    
    var ratingLabel: String {
        return "Rating: \(recommendation.rating)"
    }
    
    // This property should only be used for observation. Get and set should be done from image property.
    var dynamicImage = DynamicValue<UIImage?>(nil)
    
    var image: UIImage? {
        get {
            if dynamicImage.value == nil {
                self.delegate?.provideImage(for: self, completion: { (image) in
                    self.dynamicImage.value = image
                })
                return nil
            } else {
                return dynamicImage.value!
            }
        }
        set {
            self.dynamicImage.value = newValue
        }
    }
    
    func unwrapRecommendation() -> Recommendation {
        return self.recommendation
    }
    
}

