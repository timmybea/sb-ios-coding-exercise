//
//  RecommendationResultArchiver.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

class RecommendationResultArchiveService: ArchiveService<RecommendationResult> {
    
    static let shared: RecommendationResultArchiveService = RecommendationResultArchiveService(fileName: "recommendationResult.data")
        
    private override init(fileName: String) {
        super.init(fileName: fileName)
    }
    
    override func getAll() -> [RecommendationResult] {
        let result = super.getAll()
        print("HERE: get all \(result.count)")
        return result
    }

    override func save(_ object: RecommendationResult) {
        print("HERE: saving ")
        super.save(object)
    }

}
