//
//  SearchController.swift
//  Cooktify
//
//  Created by user on 2026/05/08.
//

import UIKit

class SearchController: UIViewController {
    private var searchResults: [Recipe] = []
    private var hasUserTyped = false
    
    // MARK: - UI Components
    
    // 1. Header (Avatar - Logo - Settings)
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.crop.circle.fill")) // Thay bằng ảnh thật "user_avatar" nếu có
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "Cookify"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let settingsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gearshape"), for: .normal)
        btn.tintColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // 2. Search Bar
    let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Recipes, ingredients, ..."
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconView.tintColor = .gray
        tf.leftView = iconView
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // 3. Recent Section
    let recentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Recent"
        lbl.font = .boldSystemFont(ofSize: 20)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let recentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // 4. Section Title
    let sectionTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Top Discoveries"
        lbl.font = .boldSystemFont(ofSize: 22)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // 5. Collection View cho kết quả
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        setupUI()
        setupRecentTags()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.identifier)
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        loadTopDiscoveries()
        
        // Thêm cử chỉ chạm (Tap Gesture) vào View chính
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Quan trọng: Để không làm ảnh hưởng đến việc nhấn vào các Cell của CollectionView
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func searchTextChanged() {
        hasUserTyped = true
        let keyword = searchTextField.text ?? ""
        searchResults = RecipeDatabase.shared.searchRecipes(keyword: keyword)
        sectionTitleLabel.text = keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Top Discoveries" : "Search Results"
        collectionView.reloadData()
    }

    private func loadTopDiscoveries() {
        searchResults = RecipeDatabase.shared.fetchAllRecipes()
        sectionTitleLabel.text = "Top Discoveries"
        collectionView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(logoLabel)
        headerView.addSubview(settingsButton)
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchTextField)
        view.addSubview(recentLabel)
        view.addSubview(recentStack)
        view.addSubview(sectionTitleLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            // Header Cookify
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            logoLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            avatarImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            settingsButton.trailingAnchor.constraint(equalTo:headerView.trailingAnchor),
            settingsButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 30),
            settingsButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Search Bar
            searchContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            searchTextField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 15),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -15),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            
            // Recent Section
            recentLabel.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 25),
            recentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            recentStack.topAnchor.constraint(equalTo: recentLabel.bottomAnchor, constant: 12),
            recentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Section Title (Top Discoveries)
            sectionTitleLabel.topAnchor.constraint(equalTo: recentStack.bottomAnchor, constant: 30),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Collection Results
            collectionView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupRecentTags() {
        let tags = ["Sourdough", "Vegan Pasta", "Matcha"]
        for tag in tags {
            let btn = UIButton(type: .system)
            btn.setTitle("  \(tag)  ", for: .normal)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.backgroundColor = .white
            btn.layer.cornerRadius = 15
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.systemGray5.cgColor
            btn.addTarget(self, action: #selector(recentTagTapped(_:)), for: .touchUpInside)
            recentStack.addArrangedSubview(btn)
        }
    }

    @objc private func recentTagTapped(_ sender: UIButton) {
        let keyword = sender.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchTextField.text = keyword
        searchTextChanged()
    }

    private func openRecipeDetail(recipeId: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailController") as? RecipeDetailController else { return }
        detailVC.recipeId = recipeId

        if let navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: detailVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}

// MARK: - Data Source & Delegate
extension SearchController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
        
        // BẬT chế độ tìm kiếm để ẩn nút tim
        cell.isSearchMode = true
        cell.configure(with: searchResults[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openRecipeDetail(recipeId: searchResults[indexPath.item].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 40, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
}
