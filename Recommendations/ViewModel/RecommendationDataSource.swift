//
//  RecommendationDataSource.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-06.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

//MARK: GenericDataSource
class GenericDataSource<T> : NSObject {
    var data: DynamicValue<[T]> = DynamicValue([])
}

//MARK: RecommendationDataSource
class RecommendationDataSource: GenericDataSource<RecommendationViewModel>, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecommendationTableViewCell
        
        cell.recommendationViewModel = data.value[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
}
