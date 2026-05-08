//
//  ViewController.swift
//  Cooktify
//
//  Created by user on 2026/05/02.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupCollectionView()
        }
        
    private func setupCollectionView() {
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.showsVerticalScrollIndicator = false
    }
}
// MARK: - Data Source (Chỉ lo về dữ liệu)
extension HomeController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedRecipeCell", for: indexPath) as! FeaturedRecipeCell
            // Ngắn gọn: Gọi một hàm duy nhất để đổ data
            cell.configure(title: "Green Goddess Glow Bowl", time: "15 min prep", rating: "4.9")
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath)
    }
}

// MARK: - Layout (Chỉ lo về kích thước)
extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        return indexPath.section == 0 ? CGSize(width: width, height: 350) : CGSize(width: (width - 15) / 2, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: section == 0 ? 10 : 20, right: 16)
    }
}

