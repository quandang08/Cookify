//
//  EditRecipeController.swift
//  Cooktify
//
//  Created by user on 2026/05/12.
//

import UIKit

class EditRecipeController: BaseRecipeFormController {
    var recipeToEdit: Recipe?

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
        // Đổ rating vào giao diện: Index 0 tương ứng 1 sao, Index 4 tương ứng 5 sao
        let ratingValue = Int((recipe.rating ?? 1).rounded())
        ratingSegment.selectedSegmentIndex = max(0, min(4, ratingValue - 1))
    }
    
    override func handleSaveAction() {
        print("Backend Quân: Đang thực thi logic UPDATE cho ID \(recipeToEdit?.id ?? 0)...")
        // Viết code PUT dữ liệu ở đây
        dismiss(animated: true)
    }
}
