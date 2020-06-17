//
//  RecommendationService.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

//MARK: BaseWebService
class BaseWebService {
        
        enum WebServiceError: Error {
            case invalidResponse
            case statusCode
            case noData
            case parsing
        }
    
}

//MARK: RecommendationService
class RecommendationService: BaseWebService {
    
    func getRecommendedTitles(session: URLSession = URLSession(configuration: .default), _ completion: @escaping(Swift.Result<RecommendationResult, Swift.Error>) ->()) {
        guard let url = URL(string: "https://www.address-does-not-matter.com") else { fatalError() }
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let receivedData = data else {
                completion(.failure(WebServiceError.noData))
                return
            }
            
            guard let responseHTTPURL = response as? HTTPURLResponse else {
                completion(.failure(WebServiceError.invalidResponse))
                return
            }
            
            switch responseHTTPURL.statusCode {
            case 200...300:
                
                do {
                    let recommendationResult = try JSONDecoder().decode(RecommendationResult.self, from: receivedData)
                    completion(.success(recommendationResult))
                }
                catch {
                    completion(.failure(WebServiceError.parsing))
                }
            default:
                completion(.failure(WebServiceError.statusCode))
                return
            }
        })

        task.resume()
    }
    
}
