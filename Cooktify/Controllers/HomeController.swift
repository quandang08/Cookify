//
//  ViewController.swift
//  Cooktify
//
//  Created by user on 2026/05/02.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!

    private let primaryGreen = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)

    private let featuredRecipe = HomeRecipeCard(
        title: "Green Goddess Glow Bowl",
        subtitle: "Healthy Choice",
        time: "15 min prep",
        rating: "4.9",
        difficulty: "Easy",
        imageName: "avocado_bowl"
    )

    private let recipes: [HomeRecipeCard] = [
        HomeRecipeCard(title: "Avocado Toast", subtitle: "Breakfast", time: "15 min", rating: "4.8", difficulty: "Easy", imageName: "avocado"),
        HomeRecipeCard(title: "Lemon Ricotta Pasta", subtitle: "Dinner", time: "25 min", rating: "4.7", difficulty: "Medium", imageName: nil),
        HomeRecipeCard(title: "Matcha Pancakes", subtitle: "Dessert", time: "20 min", rating: "4.6", difficulty: "Easy", imageName: nil),
        HomeRecipeCard(title: "Quinoa Power Bowl", subtitle: "Healthy", time: "18 min", rating: "4.9", difficulty: "Easy", imageName: "avocado_bowl")
    ]

    // Khai báo nút Floating Action Button
    let addButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        btn.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
        btn.layer.cornerRadius = 30
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
        mainCollectionView.backgroundColor = .systemBackground
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.contentInsetAdjustmentBehavior = .never

        // Dùng cell code mới thay cho prototype cell cũ trong storyboard.
        mainCollectionView.register(HomeFeaturedRecipeCell.self, forCellWithReuseIdentifier: HomeFeaturedRecipeCell.identifier)
        mainCollectionView.register(HomeSmallRecipeCell.self, forCellWithReuseIdentifier: HomeSmallRecipeCell.identifier)

        if let layout = mainCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 18
            layout.minimumInteritemSpacing = 14
        }

        // Storyboard đang để collection khá thấp và ngắn; runtime pin lại để phần dưới Home có không gian thở.
        mainCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 145),
            mainCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupFloatingButton() {
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }

    @objc private func didTapAddButton() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddRecipeVC") as! AddRecipeController
        addVC.modalPresentationStyle = .pageSheet

        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(addVC, animated: true, completion: nil)
    }

    private func openRecipeDetail() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailController") as? RecipeDetailController else {
            // Nếu storyboard chưa có identifier, fallback bằng scene segue cũ không dùng được với cell code.
            navigationController?.pushViewController(RecipeDetailController(), animated: true)
            return
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Data Source
extension HomeController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeaturedRecipeCell.identifier, for: indexPath) as! HomeFeaturedRecipeCell
            cell.configure(with: featuredRecipe)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSmallRecipeCell.identifier, for: indexPath) as! HomeSmallRecipeCell
        cell.configure(with: recipes[indexPath.item])
        return cell
    }
}

// MARK: - Layout + Navigation
extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openRecipeDetail()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 32
        let availableWidth = collectionView.bounds.width - horizontalPadding

        if indexPath.section == 0 {
            return CGSize(width: availableWidth, height: 360)
        }

        let itemWidth = (availableWidth - 14) / 2
        return CGSize(width: itemWidth, height: 220)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: section == 0 ? 8 : 6, left: 16, bottom: section == 0 ? 18 : 90, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        section == 0 ? 18 : 16
    }
}
