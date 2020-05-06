//
//  RecommendationTableViewCell.swift
//  Recommendations
//

import UIKit

class RecommendationTableViewCell: UITableViewCell {
    @IBOutlet weak var recommendationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var recommendationViewModel: RecommendationViewModel? {
        didSet {
            guard let viewModel = recommendationViewModel else { return }
            
            self.titleLabel.text = viewModel.titleLabel
            self.taglineLabel.text  = viewModel.taglineLabel
            self.ratingLabel.text = viewModel.ratingLabel
            
            viewModel.dynamicImage.addAndNotify(observer: self) { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.recommendationImageView?.image = viewModel.image
                }
            }
        }
    }
    
    override func prepareForReuse() {
        self.recommendationViewModel?.dynamicImage.removeAllObservers()
        self.recommendationImageView.image = nil
    }
    
}
