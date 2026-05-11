//
//  ViewController.swift
//  Cooktify
//
//  Created by user on 2026/05/02.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // Khai báo nút Floating Action Button
    let addButton: UIButton = {
        let btn = UIButton(type: .system)
        // 1. Cấu hình icon và màu sắc đúng chất Cookify
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        btn.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
        
        // 2. Bo tròn để tạo hình tròn
        btn.layer.cornerRadius = 30
        
        // 3. Đổ bóng để nút "nổi" lên trên mặt thẻ món ăn
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 5
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFloatingButton()
    }
        
    private func setupCollectionView() {
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func setupFloatingButton() {
        // Thêm nút vào view chính (đè lên trên CollectionView)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Cách mép phải 20px
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Cách mép dưới (Safe Area - trên Tab Bar) 20px
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            // Kích thước 60x60
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Thêm sự kiện khi nhấn nút
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }

    @objc private func didTapAddButton() {
        // 1. Tạo rung phản hồi (Haptic)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // 2. Khởi tạo màn hình Add Recipe từ Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddRecipeVC") as! AddRecipeController
        
        // 3. Hiển thị kiểu Page Sheet (trượt lên từ dưới)
        addVC.modalPresentationStyle = .pageSheet
        
        // 4. Cho phép kéo xuống để đóng (tùy chọn)
        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.large()] // Hiện full màn hình nhưng vẫn có thanh nắm kéo ở trên
            sheet.prefersGrabberVisible = true // Hiện cái thanh nhỏ trên đầu để kéo xuống
        }
        
        self.present(addVC, animated: true, completion: nil)
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

