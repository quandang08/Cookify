//
//  FavoriteCell.swift
//  Cooktify
//
//  Created by user on 2026/05/11.
//
import UIKit

class FavoriteCell: UICollectionViewCell {
    static let identifier = "FavoriteCell"
    
    var isSearchMode: Bool = false {
        didSet {
            // Khi biến này thay đổi, nút tim sẽ tự ẩn/hiện
            heartButton.isHidden = isSearchMode
        }
    }
    
    // MARK: - UI Components
    let foodImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let heartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        btn.tintColor = .systemGreen
        btn.backgroundColor = .white.withAlphaComponent(0.9)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGreen
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 2
        return label
    }()
    
    // Stack chứa Icon + Chữ (Thời gian, Độ khó)
    let metaStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 15
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()


    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.name
        tagLabel.text = "  \(recipe.category ?? "RECIPE")  ".uppercased()

        if let image = ImageStorageManager.shared.loadImage(named: recipe.image) {
            foodImageView.image = image
            foodImageView.contentMode = .scaleAspectFill
        } else {
            foodImageView.image = UIImage(systemName: "fork.knife.circle.fill")
            foodImageView.tintColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
            foodImageView.contentMode = .scaleAspectFit
        }

        metaStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metaStack.addArrangedSubview(createMetaItem(icon: "clock", text: "\(recipe.duration) min"))
        metaStack.addArrangedSubview(createMetaItem(icon: "flame.fill", text: recipe.difficulty))
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        // Đổ bóng cho nguyên cái Cell
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 10
        
        // Bo góc cho contentView
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(foodImageView)
        contentView.addSubview(heartButton)
        
        // Tạo Container cho phần Text để dễ padding
        let textContainer = UIStackView()
        textContainer.axis = .vertical
        textContainer.spacing = 10
        textContainer.alignment = .leading
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        
        textContainer.addArrangedSubview(tagLabel)
        textContainer.addArrangedSubview(titleLabel)
        textContainer.addArrangedSubview(metaStack)
        
        contentView.addSubview(textContainer)
        
        NSLayoutConstraint.activate([
            // Ảnh chiếm 65% chiều cao trên cùng
            foodImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            foodImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            foodImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            
            // Nút tim đè lên ảnh
            heartButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            heartButton.widthAnchor.constraint(equalToConstant: 32),
            heartButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Phần text nằm dưới ảnh
            textContainer.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 15),
            textContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    // Hàm này giúp tạo nhanh các item meta (Clock, Flame)
    func createMetaItem(icon: String, text: String) -> UIView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = .darkGray
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .darkGray
        
        view.addArrangedSubview(iv)
        view.addArrangedSubview(lbl)
        return view
    }
}
