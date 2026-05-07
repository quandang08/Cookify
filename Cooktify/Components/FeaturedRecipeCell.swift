//
//  FeaturedRecipeCell.swift
//  Cooktify
//
//  Created by user on 2026/05/07.
//

import UIKit

class FeaturedRecipeCell: UICollectionViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 24
        self.clipsToBounds = true // "cắt" ảnh thừa ở góc bo
    }
}
