//
//  RecommendationListViewModel.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-06.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

class RecommendationListViewModel {
    
    weak var dataSource: GenericDataSource<RecommendationViewModel>?
    weak var archive: ArchiveService<RecommendationResult>?
    var service: RecommendationService?
    
    private var pendingImageTasks: [URL : URLSessionDataTask] = [:]
    private var imageCache = NSCache<NSString, UIImage>()
    
    init(_ service: RecommendationService = RecommendationService(), _ archive: ArchiveService<RecommendationResult> = RecommendationResultArchiveService.shared, dataSource: GenericDataSource<RecommendationViewModel>?) {
        self.dataSource = dataSource
        self.archive = archive
        self.service = service
    }
    
    func fetchData() {
        guard let service = service, let archive = archive else {
            print("Error: Missing service")
            return
        }
        
        //Set datasource with locally stored data
        dataSource?.data.value = getTopTen(RecommendationResultArchiveService.shared.getAll().first)
        
        //Update the datasource with fresh data from url session
        service.getRecommendedTitles { (result) in
            switch result {
            case .success(let recommendationResult):
                
                archive.removeAll()
                archive.save(recommendationResult)
               
                self.dataSource?.data.value = self.getTopTen(recommendationResult)
                
            case .failure(let error):
                fatalError("Error recommendation service: \(error), File: \(#file), Line: \(#line)")
            }
        }
    }
    
    private func getTopTen(_ recommendationResult: RecommendationResult?) -> [RecommendationViewModel] {
        guard let unwrappedResult = recommendationResult else { return [] }
        let topTen = unwrappedResult.titles.filter({ $0.isReleased && !unwrappedResult.titlesOwned.contains($0.title)})
            .sorted(by: { $0.rating > $1.rating })
            .prefix(10)
            
        var output = [RecommendationViewModel]()
        for recommendation in topTen {
            let viewModel = RecommendationViewModel(recommendation)
            viewModel.delegate = self
            output.append(viewModel)
        }

        return output
    }
    
}

extension RecommendationListViewModel: RecommendationViewModelDelegate {
    
    func provideImage(for recommendationViewModel: RecommendationViewModel, completion: @escaping (UIImage?) -> ()) {
        
        let recommendation = recommendationViewModel.unwrapRecommendation()
        guard let imageURL = URL(string: recommendation.imageURL) else {
            completion(nil)
            return
        }
        
        //attempt to get image from cache
        guard let image = self.imageCache.object(forKey: NSString(string: imageURL.absoluteString)) else {

            //attempt to get image from fetch request
            let request = URLRequest(url: imageURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5.0)
            let fetchImageTask = URLSession.shared.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if let url = response?.url {
                    DispatchQueue.main.async {
                        self?.pendingImageTasks.removeValue(forKey: url)
                    }
                }
                
                //Swallow errors: If we can't get images this time, they can be fetched again at another time.
                //Kerry: This is more simple than I would like.
                guard error == nil else {
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    completion(nil)
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                
                completion(image)
            }
            
            pendingImageTasks[imageURL] = fetchImageTask
            fetchImageTask.resume()
            return
        }

        completion(image)
        return
    }
    
}
