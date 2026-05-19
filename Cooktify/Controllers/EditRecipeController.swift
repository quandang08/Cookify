//
//  EditRecipeController.swift
//  Cooktify
//
//  Created by user on 2026/05/12.
//

import UIKit

class EditRecipeController: BaseRecipeFormController {
    var recipeToEdit: Recipe?
    var onRecipeUpdated: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Edit Recipe"
        saveButton.setTitle("Update Recipe", for: .normal)
        setupData()
    }

    private func setupData() {
        guard let recipe = recipeToEdit else { return }

        nameTextField.text = recipe.name
        durationTextField.text = "\(recipe.duration)"

        if let category = recipe.category,
           let categoryIndex = ["Breakfast", "Lunch", "Dinner"].firstIndex(of: category) {
            categorySegment.selectedSegmentIndex = categoryIndex
        }

        if let difficultyIndex = ["Easy", "Medium", "Hard"].firstIndex(of: recipe.difficulty) {
            difficultySegment.selectedSegmentIndex = difficultyIndex
        }

        let ratingValue = Int((recipe.rating ?? 1).rounded())
        ratingSegment.selectedSegmentIndex = max(0, min(4, ratingValue - 1))

        ingredientsTextView.text = recipe.ingredients
            .map { ingredient in
                if let quantity = ingredient.quantity, !quantity.isEmpty {
                    return "\(quantity) \(ingredient.name)"
                }
                return ingredient.name
            }
            .joined(separator: "\n")

        if let image = ImageStorageManager.shared.loadImage(named: recipe.image) {
            recipeImageView.image = image
            selectedRecipeImage = image
            didChangeRecipeImage = false
        }

        stepsTextView.text = recipe.steps
            .sorted { $0.stepNumber < $1.stepNumber }
            .map { $0.description }
            .joined(separator: "\n")
    }

    override func handleSaveAction() {
        guard var recipe = recipeToEdit else { return }

        let recipeName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !recipeName.isEmpty else {
            showAlert(title: "Missing recipe name", message: "Please enter a recipe name before updating.")
            return
        }

        let durationText = durationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        recipe.name = recipeName
        recipe.duration = Int(durationText) ?? 0
        if didChangeRecipeImage, let selectedRecipeImage {
            recipe.image = ImageStorageManager.shared.saveImage(selectedRecipeImage) ?? recipe.image
        }

        recipe.category = selectedCategory()
        recipe.difficulty = selectedDifficulty()
        recipe.rating = selectedRating()
        recipe.ingredients = parsedIngredients(recipeId: recipe.id)
        recipe.steps = parsedSteps(recipeId: recipe.id)

        RecipeDatabase.shared.updateRecipe(recipe)
        print("Backend Quân: Đã UPDATE recipe ID \(recipe.id)")
        onRecipeUpdated?()
        dismiss(animated: true)
    }
}
