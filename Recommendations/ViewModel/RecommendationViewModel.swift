//
//  RecommendationViewModel.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-06.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

//MARK: RecommendationViewModelDelegate
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
    
    private var dynamicImage = DynamicValue<UIImage?>(nil)
    
    func addObserverForImageAndNotify(_ observer: NSObject, completionHandler: @escaping CompletionHandler) {
        dynamicImage.addAndNotify(observer: observer, completionHandler: completionHandler)
    }
    
    func removeImageUpdateObservers() {
        dynamicImage.removeAllObservers()
    }
    
    func unwrapRecommendation() -> Recommendation {
        return self.recommendation
    }
    
}

