//
//  CategoryCell.swift
//  Cooktify
//
//  Created by user on 2026/05/06.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true

        self.backgroundColor = UIColor.systemGray6
        
    }
}
