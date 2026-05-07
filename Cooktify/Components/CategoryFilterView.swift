//
//  CategoryFilterView.swift
//  Cooktify
//
//  Created by user on 2026/05/06.
//

import UIKit

class CategoryFilterView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    // MARK: - Constants & Properties
    let categories = ["All", "Breakfast", "Lunch", "Dinner", "Dessert", "Drinks"]
    var selectedIndex = 0
    
    // Màu xanh chủ đạo của app (#064E3B)
    private let primaryGreen = UIColor(red: 0.02, green: 0.31, blue: 0.23, alpha: 1.0)
    private let inactiveGray = UIColor.systemGray6

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
        
    private func setupCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.showsHorizontalScrollIndicator = false
    }
}

// MARK: - UICollectionView Extensions
extension CategoryFilterView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
            
        let isSelected = indexPath.item == selectedIndex
        configureCell(cell, for: indexPath.item, isSelected: isSelected)
            
        return cell
    }
        
    private func configureCell(_ cell: CategoryCell, for index: Int, isSelected: Bool) {
        cell.categoryLabel.text = categories[index]
        cell.backgroundColor = isSelected ? primaryGreen : inactiveGray
        cell.categoryLabel.textColor = isSelected ? .white : .black
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
            
        // Luôn cuộn ô được chọn vào giữa màn hình
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        print("Backend Log: Filtering recipes for category -> \(categories[selectedIndex])")
    }
        
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let name = categories[indexPath.item]
            let font = UIFont.systemFont(ofSize: 15)
            let width = name.size(withAttributes: [.font: font]).width + 36 // Tăng padding một chút
            
            return CGSize(width: width, height: 40)
        }
    }
