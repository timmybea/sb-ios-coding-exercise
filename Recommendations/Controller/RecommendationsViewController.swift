//
//  ViewController.swift
//  Recommendations
//

import UIKit
import OHHTTPStubs

class RecommendationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
        
    let dataSource = RecommendationDataSource()
    
    lazy var viewModel: RecommendationListViewModel = {
        let viewModel = RecommendationListViewModel(dataSource: self.dataSource)
        return viewModel
    }()
    
//    private var pendingImageTasks: [URL : URLSessionDataTask] = [:]
//    
//    private var imageCache = NSCache<NSString, UIImage>()
    
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
        tableView.dataSource = self.dataSource
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        self.viewModel.fetchData()
        
    }
    
}

//MARK: Image Caching
//extension RecommendationsViewController {
//
//    private func fetchImage(at url: URL, completion: @escaping (Swift.Result<UIImage, Swift.Error>) -> ()) {
//        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5.0)
//        let fetchImageTask = URLSession.shared.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//            if let url = response?.url {
//                DispatchQueue.main.async {
//                    self?.pendingImageTasks.removeValue(forKey: url)
//                }
//            }
//
//            let result = Swift.Result<UIImage, Swift.Error> {
//                guard error == nil else { throw error! }
//                guard let _ = data else { throw NSError(domain: "com.recommendations.demo", code: -1) }
//                guard let image = UIImage(data: data!) else { throw NSError(domain: "com.recommendations.demo", code: -1) }
//                return image
//            }
//
//            completion(result)
//        }
//
//        pendingImageTasks[url] = fetchImageTask
//        fetchImageTask.resume()
//    }
//
//}
