//
//  RecommendationResultArchiver.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

//MARK: RecommendationResultArchiveService
class RecommendationResultArchiveService: ArchiveService<RecommendationResult> {
    
    static let shared: RecommendationResultArchiveService = RecommendationResultArchiveService(fileName: "recommendationResult.data")
        
    private override init(fileName: String) {
        super.init(fileName: fileName)
    }

}
