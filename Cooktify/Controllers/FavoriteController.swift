//
//  FavoriteController.swift
//  Cooktify
//
//  Created by user on 2026/05/08.
//

import UIKit

class FavoriteController: UIViewController {
    private var favoriteRecipes: [Recipe] = []
    private let primaryGreen = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)

    // MARK: - Header UI Components
    let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        iv.tintColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
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

    let bigTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorites"
        label.font = .boldSystemFont(ofSize: 36)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your curated collection of culinary inspiration."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite recipes yet. Tap the heart on a recipe to save it here."
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - CollectionView
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        navigationController?.isNavigationBarHidden = true

        setupUI()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.identifier)
        loadFavoriteRecipes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriteRecipes()
    }

    private func loadFavoriteRecipes() {
        favoriteRecipes = RecipeDatabase.shared.fetchFavoriteRecipes()
        emptyLabel.isHidden = !favoriteRecipes.isEmpty
        collectionView.reloadData()
    }

    private func removeFavorite(recipeId: Int) {
        RecipeDatabase.shared.toggleFavorite(recipeId: recipeId)
        loadFavoriteRecipes()
    }

    private func setupUI() {
        view.addSubview(headerContainer)
        headerContainer.addSubview(avatarImageView)
        headerContainer.addSubview(logoLabel)
        headerContainer.addSubview(settingsButton)
        headerContainer.addSubview(bigTitleLabel)
        headerContainer.addSubview(subtitleLabel)

        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            avatarImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: logoLabel.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            logoLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),

            settingsButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            settingsButton.centerYAnchor.constraint(equalTo: logoLabel.centerYAnchor),

            bigTitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 30),
            bigTitleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: bigTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -10),

            collectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            emptyLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -30)
        ])
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

extension FavoriteController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favoriteRecipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
        let recipe = favoriteRecipes[indexPath.item]
        cell.configure(with: recipe)
        cell.isSearchMode = false
        cell.onFavoriteButtonTapped = { [weak self] in
            self?.removeFavorite(recipeId: recipe.id)
        }
        cell.onDeleteRecipeTapped = { [weak self] in
            self?.removeFavorite(recipeId: recipe.id)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openRecipeDetail(recipeId: favoriteRecipes[indexPath.item].id)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 40
        return CGSize(width: width, height: 350)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        25
    }
}
