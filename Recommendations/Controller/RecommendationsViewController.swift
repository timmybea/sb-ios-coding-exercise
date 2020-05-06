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
