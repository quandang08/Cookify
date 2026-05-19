import UIKit

class AddRecipeController: BaseRecipeFormController {
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Add New Recipe"
        saveButton.setTitle("Save Recipe", for: .normal)
    }

    override func handleSaveAction() {
        let recipeName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !recipeName.isEmpty else {
            showAlert(title: "Missing recipe name", message: "Please enter a recipe name before saving.")
            return
        }

        let durationText = durationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let duration = Int(durationText) ?? 0

        let recipe = Recipe(
            id: 0,
            name: recipeName,
            image: nil,
            category: selectedCategory(),
            duration: duration,
            rating: selectedRating(),
            difficulty: selectedDifficulty(),
            isFavorite: false,
            createdAt: Recipe.currentDateString(),
            ingredients: parsedIngredients(),
            steps: parsedSteps()
        )

        if RecipeDatabase.shared.createRecipe(recipe) != nil {
            print("Backend Quân: Đã CREATE recipe mới: \(recipeName)")
            dismiss(animated: true)
        } else {
            showAlert(title: "Save failed", message: "Could not save this recipe. Please try again.")
        }
    }
}
