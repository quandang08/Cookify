//
//  RecipeDetailController.swift
//  Cooktify
//
//  Created by user on 2026/05/08.
//

import UIKit

class RecipeDetailController: UIViewController {
    var recipeId: Int?
    var currentRecipe: Recipe?

    private let primaryGreen = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
    private let creamBackground = UIColor(red: 248/255, green: 247/255, blue: 238/255, alpha: 1.0)
    private let softGreen = UIColor(red: 226/255, green: 239/255, blue: 211/255, alpha: 1.0)

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecipeFromDatabaseIfNeeded()
        setupNavigationAppearance()
        setupDynamicDetailUI()
    }

    private func loadRecipeFromDatabaseIfNeeded() {
        guard let recipeId else { return }
        currentRecipe = RecipeDatabase.shared.fetchRecipeDetail(id: recipeId)
        RecipeDatabase.shared.addRecentlyViewed(recipeId: recipeId)
    }

    // MARK: - UI Setup
    private func setupNavigationAppearance() {
        title = nil
        navigationController?.navigationBar.tintColor = primaryGreen
    }

    private func setupDynamicDetailUI() {
        // Storyboard detail cũ dùng nhiều fixed frame nên dễ tạo khoảng trắng.
        // Xóa phần view cũ và dựng lại bằng StackView để nội dung tự kéo dài theo data.
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = creamBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset.bottom = 28
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        setupStartButton()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])

        contentStack.addArrangedSubview(makeHeroView())
        contentStack.addArrangedSubview(makeInfoSection())
        contentStack.addArrangedSubview(makeIngredientsSection())
        contentStack.addArrangedSubview(makeInstructionsSection())
    }

    private func setupStartButton() {
        startButton.setTitle("Start Cooking", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.backgroundColor = primaryGreen
        startButton.layer.cornerRadius = 18
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.12
        startButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        startButton.layer.shadowRadius = 14
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func makeHeroView() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 224/255, alpha: 1.0)
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = primaryGreen
        imageView.image = UIImage(systemName: "fork.knife.circle.fill")

        if let imageName = currentRecipe?.image, let image = UIImage(named: imageName) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }

        let badge = UILabel()
        badge.text = "  Chef's Pick  "
        badge.textColor = primaryGreen
        badge.font = .systemFont(ofSize: 15, weight: .bold)
        badge.backgroundColor = softGreen
        badge.layer.cornerRadius = 17
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        container.addSubview(badge)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 285),

            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 18),
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.64),
            imageView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.64),

            badge.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            badge.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            badge.heightAnchor.constraint(equalToConstant: 34)
        ])

        return container
    }

    private func makeInfoSection() -> UIView {
        let wrapper = paddedVerticalStack()

        let titleLabel = UILabel()
        titleLabel.text = currentRecipe?.name ?? "Creamy Lemon Ricotta Pasta"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let ratingStack = UIStackView()
        ratingStack.axis = .horizontal
        ratingStack.spacing = 5
        ratingStack.alignment = .center
        let ratingValue = currentRecipe?.rating ?? 4.8
        for index in 1...5 {
            let star = UIImageView(image: UIImage(systemName: Double(index) <= ratingValue.rounded() ? "star.fill" : "star"))
            star.tintColor = .systemYellow
            star.contentMode = .scaleAspectFit
            star.widthAnchor.constraint(equalToConstant: 20).isActive = true
            star.heightAnchor.constraint(equalToConstant: 20).isActive = true
            ratingStack.addArrangedSubview(star)
        }

        let ratingText = UILabel()
        ratingText.text = String(format: "  %.1f (128 reviews)", ratingValue)
        ratingText.font = .systemFont(ofSize: 15, weight: .medium)
        ratingText.textColor = .secondaryLabel
        ratingStack.addArrangedSubview(ratingText)

        let metaStack = UIStackView(arrangedSubviews: [
            makeMetaPill(icon: "clock", text: "\(currentRecipe?.duration ?? 25) min"),
            makeMetaPill(icon: "fork.knife", text: currentRecipe?.difficulty ?? "Easy")
        ])
        metaStack.axis = .horizontal
        metaStack.spacing = 12
        metaStack.distribution = .fillEqually

        wrapper.addArrangedSubview(titleLabel)
        wrapper.addArrangedSubview(ratingStack)
        wrapper.addArrangedSubview(metaStack)
        return wrapper
    }

    private func makeIngredientsSection() -> UIView {
        let wrapper = paddedVerticalStack()
        wrapper.spacing = 16

        wrapper.addArrangedSubview(makeSectionTitle("Ingredients"))

        let ingredients = currentRecipe?.ingredients ?? []

        if ingredients.isEmpty {
            wrapper.addArrangedSubview(makeEmptyLabel("No ingredients yet."))
            return wrapper
        }

        for ingredient in ingredients {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 14

            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            button.tintColor = primaryGreen
            button.widthAnchor.constraint(equalToConstant: 28).isActive = true
            button.heightAnchor.constraint(equalToConstant: 28).isActive = true
            button.addTarget(self, action: #selector(ingredientTapped(_:)), for: .touchUpInside)

            let label = UILabel()
            if let quantity = ingredient.quantity, !quantity.isEmpty {
                label.text = "\(quantity) \(ingredient.name)"
            } else {
                label.text = ingredient.name
            }
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.numberOfLines = 0

            row.addArrangedSubview(button)
            row.addArrangedSubview(label)
            wrapper.addArrangedSubview(row)
        }

        return wrapper
    }

    private func makeInstructionsSection() -> UIView {
        let wrapper = paddedVerticalStack()
        wrapper.spacing = 18

        wrapper.addArrangedSubview(makeSectionTitle("Instructions"))

        let instructions = currentRecipe?.steps ?? []

        if instructions.isEmpty {
            wrapper.addArrangedSubview(makeEmptyLabel("No instructions yet."))
            return wrapper
        }

        for instruction in instructions {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .top
            row.spacing = 14

            let numberLabel = UILabel()
            numberLabel.text = "\(instruction.stepNumber)"
            numberLabel.textColor = .white
            numberLabel.font = .systemFont(ofSize: 15, weight: .bold)
            numberLabel.textAlignment = .center
            numberLabel.backgroundColor = primaryGreen
            numberLabel.layer.cornerRadius = 14
            numberLabel.clipsToBounds = true
            numberLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
            numberLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true

            let textLabel = UILabel()
            textLabel.text = instruction.description
            textLabel.font = .systemFont(ofSize: 17, weight: .regular)
            textLabel.textColor = .label
            textLabel.numberOfLines = 0

            row.addArrangedSubview(numberLabel)
            row.addArrangedSubview(textLabel)
            wrapper.addArrangedSubview(row)
        }

        return wrapper
    }

    private func makeEmptyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = primaryGreen
        return label
    }

    private func makeMetaPill(icon: String, text: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 16
        stack.layer.borderWidth = 1
        stack.layer.borderColor = UIColor.systemGray6.cgColor

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = primaryGreen
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        stack.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return stack
    }

    private func paddedVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return stack
    }

    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Delete Recipe?",
            message: "Are you sure you want to delete this recipe? This action cannot be undone.",
            preferredStyle: .alert
        )

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.handleDeleteLogic()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditRecipeController") as? EditRecipeController else { return }
        editVC.recipeToEdit = currentRecipe
        present(editVC, animated: true)
    }

    private func handleDeleteLogic() {
        print("Backend Quân: Đang thực thi xóa dữ liệu...")
        navigationController?.popViewController(animated: true)
    }

    @IBAction func ingredientTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
}
