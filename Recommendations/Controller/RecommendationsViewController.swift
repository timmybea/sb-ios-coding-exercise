//
//  ViewController.swift
//  Recommendations
//

import UIKit
import OHHTTPStubs

class RecommendationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
        
    private var recommendations = [Recommendation]()
    
    private var pendingImageTasks: [URL : URLSessionDataTask] = [:]
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---------------------------------------------------
        // -------- <DO NOT MODIFY INSIDE THIS BLOCK> --------
        // stub the network response with our local ratings.json file
        let stub = Stub()
        stub.registerStub()
        // -------- </DO NOT MODIFY INSIDE THIS BLOCK> -------
        // ---------------------------------------------------
        
        tableView.register(UINib(nibName: "RecommendationTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
//        tableView.delegate = self
        
        self.recommendations = getTopTen(RecommendationResultArchiveService.shared.getAll().first)
        self.tableView.reloadData()
        
        // NOTE: please maintain the stubbed url we use here and the usage of
        // a URLSession dataTask to ensure our stubbed response continues to
        // work; however, feel free to reorganize/rewrite/refactor as needed
        RecommendationService().getRecommendedTitles { (result) in
            switch result {
            case .success(let recommendationResult):
                
                RecommendationResultArchiveService.shared.removeAll()
                RecommendationResultArchiveService.shared.save(recommendationResult)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.recommendations = self.getTopTen(recommendationResult)
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                fatalError("Error recommendation service: \(error), File: \(#file), Line: \(#line)")
            }
        }
        
    }
    
}

//MARK: Filter Top Ten Titles
extension RecommendationsViewController {
    
    private func getTopTen(_ recommendationResult: RecommendationResult?) -> [Recommendation] {
          guard let unwrappedResult = recommendationResult else { return [] }
          let topTen = unwrappedResult.titles.filter({ $0.isReleased && !unwrappedResult.titlesOwned.contains($0.title)})
              .sorted(by: { $0.rating > $1.rating })
              .prefix(10)
          return Array(topTen)
    }
    
}

//MARK: Image Caching
extension RecommendationsViewController {

    private func fetchImage(at url: URL, completion: @escaping (Swift.Result<UIImage, Swift.Error>) -> ()) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5.0)
        let fetchImageTask = URLSession.shared.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in

            if let url = response?.url {
                DispatchQueue.main.async {
                    self?.pendingImageTasks.removeValue(forKey: url)
                }
            }

            let result = Swift.Result<UIImage, Swift.Error> {
                guard error == nil else { throw error! }
                guard let _ = data else { throw NSError(domain: "com.recommendations.demo", code: -1) }
                guard let image = UIImage(data: data!) else { throw NSError(domain: "com.recommendations.demo", code: -1) }
                return image
            }

            completion(result)
        }

        pendingImageTasks[url] = fetchImageTask
        fetchImageTask.resume()
    }

}

//MARK: UITableViewDataSource
extension RecommendationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecommendationTableViewCell
         
         let recommendation = recommendations[indexPath.row]

         cell.titleLabel.text = recommendation.title
         cell.taglineLabel.text = recommendation.tagline
         cell.ratingLabel.text = "Rating: \(recommendation.rating)"
         
         guard let imageURL = URL(string: recommendation.imageURL) else { return cell }
         
         //Attempt to retrieve the image from the cache
         guard let image = self.imageCache.object(forKey: NSString(string: imageURL.absoluteString)) else {
             self.fetchImage(at: imageURL) { [weak self] (result) in
                 guard let self = self else { return }
                 
                 switch result {
                 case .success(let image):
                     self.imageCache.setObject(image, forKey: NSString(string: imageURL.absoluteString))
                     
                     DispatchQueue.main.async { [weak self] in
                         guard let self = self else { return }

                         //Ensure that the cell is still visible (This would typically be a unique title id)
                         guard let index = self.recommendations.firstIndex(where: { $0.title == recommendation.title }),
                             index == indexPath.row else { return }
                         
                         guard (self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) else { return }
                         
                         //Get the cell and set the image
                         guard let cell = self.tableView.cellForRow(at: indexPath) as? RecommendationTableViewCell else { return }
                         cell.recommendationImageView?.image = image
                     }
                 case .failure(let error):
                     print("Error fetching image: \(imageURL.absoluteString): Error: \(error.localizedDescription)")
                 }
             }
             return cell
         }

         cell.recommendationImageView?.image = image
         return cell
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return recommendations.count
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }
     
     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return 134
     }
    
}
