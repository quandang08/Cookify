//
//  RecipeCell.swift
//  Cooktify
//
//  Created by user on 2026/05/11.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    static let identifier = "RecipeCell"
        
        private let recipeImageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 20
            iv.backgroundColor = .systemGray6 // Hiện màu xám để Quân dễ thấy khi chưa có ảnh
            return iv
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            contentView.addSubview(recipeImageView)
            recipeImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                recipeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                recipeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor) // Cho hình tràn hết cell
            ])
        }
}
