//
//  ViewController.swift
//  Recommendations
//

import UIKit
import OHHTTPStubs

class RecommendationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var recommendationResult: RecommendationResult? {
        didSet {
            self.recommendations = recommendationResult?.titles ?? []
        }
    }
    
    var recommendations = [Recommendation]()
    
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
        tableView.delegate = self
        
        // NOTE: please maintain the stubbed url we use here and the usage of
        // a URLSession dataTask to ensure our stubbed response continues to
        // work; however, feel free to reorganize/rewrite/refactor as needed
        RecommendationService().getRecommendedTitles { (result) in
            switch result {
            case .success(let recommendationResult):
                self.recommendationResult = recommendationResult
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                fatalError("Error recommendation service: \(error), File: \(#file), Line: \(#line)")
            }
        }
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecommendationTableViewCell
        
        let recommendation = recommendations[indexPath.row]

        cell.titleLabel.text = recommendation.title
        cell.taglineLabel.text = recommendation.tagline
        cell.ratingLabel.text = "Rating: \(recommendation.rating)"
        
        if let url = URL(string: recommendation.imageURL) {
            let data = try? Data(contentsOf: url)

            if let imageData = data {
                let image = UIImage(data: imageData)
                cell.recommendationImageView?.image = image
            }
        }

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
