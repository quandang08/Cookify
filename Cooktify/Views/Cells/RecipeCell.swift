//
//  RecipeCell.swift
//  Cooktify
//
//  Created by user on 2026/05/11.
//

import UIKit

struct HomeRecipeCard {
    let id: Int?
    let title: String
    let subtitle: String
    let time: String
    let rating: String
    let difficulty: String
    let imageName: String?
}

class RecipeCell: UICollectionViewCell {
    static let identifier = "RecipeCell"

    private let recipeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .systemGray6
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
            recipeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

final class HomeFeaturedRecipeCell: UICollectionViewCell {
    static let identifier = "HomeFeaturedRecipeCell"

    private let imageView = UIImageView()
    private let gradientView = UIView()
    private let tagLabel = UILabel()
    private let heartButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let timePill = UIStackView()
    private let ratingPill = UIStackView()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 28).cgPath
    }

    func configure(with recipe: HomeRecipeCard) {
        titleLabel.text = recipe.title
        tagLabel.text = "  \(recipe.subtitle)  "
        configurePill(timePill, icon: "clock", text: recipe.time, iconColor: .white)
        configurePill(ratingPill, icon: "star.fill", text: recipe.rating, iconColor: .systemYellow)

        if let image = ImageStorageManager.shared.loadImage(named: recipe.imageName) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.image = UIImage(systemName: "birthday.cake.fill")
            imageView.tintColor = .systemBlue
            imageView.contentMode = .scaleAspectFit
        }
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 28
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 18

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        contentView.addSubview(imageView)

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.02).cgColor,
            UIColor.black.withAlphaComponent(0.20).cgColor,
            UIColor.black.withAlphaComponent(0.78).cgColor
        ]
        gradientLayer.locations = [0.0, 0.48, 1.0]
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.addSublayer(gradientLayer)
        contentView.addSubview(gradientView)

        tagLabel.font = .systemFont(ofSize: 15, weight: .bold)
        tagLabel.textColor = UIColor(red: 92/255, green: 108/255, blue: 73/255, alpha: 1)
        tagLabel.backgroundColor = UIColor(red: 218/255, green: 232/255, blue: 196/255, alpha: 1)
        tagLabel.layer.cornerRadius = 18
        tagLabel.clipsToBounds = true
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagLabel)

        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1)
        heartButton.backgroundColor = .white
        heartButton.layer.cornerRadius = 28
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heartButton)

        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        let bottomStack = UIStackView(arrangedSubviews: [timePill, ratingPill])
        bottomStack.axis = .horizontal
        bottomStack.spacing = 12
        bottomStack.alignment = .leading
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomStack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            tagLabel.heightAnchor.constraint(equalToConstant: 38),

            heartButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            heartButton.widthAnchor.constraint(equalToConstant: 56),
            heartButton.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),

            bottomStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            bottomStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),
            bottomStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            timePill.heightAnchor.constraint(equalToConstant: 38),
            ratingPill.heightAnchor.constraint(equalToConstant: 38)
        ])
    }

    private func configurePill(_ stack: UIStackView, icon: String, text: String, iconColor: UIColor) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.axis = .horizontal
        stack.spacing = 7
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 14)
        stack.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        stack.layer.cornerRadius = 19
        stack.clipsToBounds = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
    }
}

final class HomeSmallRecipeCell: UICollectionViewCell {
    static let identifier = "HomeSmallRecipeCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let metaLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with recipe: HomeRecipeCard) {
        titleLabel.text = recipe.title
        subtitleLabel.text = recipe.subtitle
        metaLabel.text = recipe.time
        ratingLabel.text = "★ \(recipe.rating)"

        if let image = ImageStorageManager.shared.loadImage(named: recipe.imageName) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.image = UIImage(systemName: "fork.knife.circle.fill")
            imageView.tintColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1)
            imageView.contentMode = .scaleAspectFit
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 22
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12

        imageView.backgroundColor = UIColor(red: 245/255, green: 244/255, blue: 235/255, alpha: 1)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        subtitleLabel.textColor = .systemGreen

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2

        metaLabel.font = .systemFont(ofSize: 12, weight: .medium)
        metaLabel.textColor = .secondaryLabel

        ratingLabel.font = .systemFont(ofSize: 12, weight: .bold)
        ratingLabel.textColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1)

        let bottomStack = UIStackView(arrangedSubviews: [metaLabel, ratingLabel])
        bottomStack.axis = .horizontal
        bottomStack.distribution = .equalSpacing

        let textStack = UIStackView(arrangedSubviews: [subtitleLabel, titleLabel, bottomStack])
        textStack.axis = .vertical
        textStack.spacing = 7
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.56),

            textStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
