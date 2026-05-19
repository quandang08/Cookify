//
//  BaseRecipeFormController.swift
//  Cooktify
//
//  Created by user on 2026/05/12.
//

import UIKit

class BaseRecipeFormController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UI Components (Các thành phần dùng chung cho cả Add và Edit)
        let scrollView: UIScrollView = {
            let sv = UIScrollView()
            sv.translatesAutoresizingMaskIntoConstraints = false
            return sv
        }()
        
        let contentView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let titleLabel: UILabel = {
            let lbl = UILabel()
            lbl.font = .boldSystemFont(ofSize: 28)
            lbl.textColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
            return lbl
        }()

        let recipeImageView: UIImageView = {
            let iv = UIImageView()
            iv.backgroundColor = .systemGray6
            iv.contentMode = .scaleAspectFill
            iv.layer.cornerRadius = 20
            iv.clipsToBounds = true
            iv.isUserInteractionEnabled = true
            iv.image = UIImage(systemName: "photo.on.rectangle.angled")
            iv.tintColor = .systemGray3
            return iv
        }()

        let nameTextField = UITextField.createStandard(placeholder: "Recipe Name")
        let durationTextField = UITextField.createStandard(placeholder: "Duration (mins)", keyboard: .numberPad)
        
        let categorySegment: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["Breakfast", "Lunch", "Dinner"])
            sc.selectedSegmentIndex = 0
            return sc
        }()
        
        let difficultySegment: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["Easy", "Medium", "Hard"])
            sc.selectedSegmentIndex = 0
            return sc
        }()
    
        let ratingSegment: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["1 ⭐", "2 ⭐", "3 ⭐", "4 ⭐", "5 ⭐"])
            sc.selectedSegmentIndex = 0
            return sc
        }()
        
        let ingredientsTextView = UITextView.createStandard()
        let stepsTextView = UITextView.createStandard()

        let saveButton: UIButton = {
            let btn = UIButton(type: .system)
            btn.backgroundColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
            btn.layer.cornerRadius = 15
            return btn
        }()

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupBaseUI()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
            recipeImageView.addGestureRecognizer(tap)

            let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            dismissKeyboardTap.cancelsTouchesInView = false
            view.addGestureRecognizer(dismissKeyboardTap)
            
            // Gán hành động cho nút Save (Sẽ được ghi đè ở class con)
            saveButton.addTarget(self, action: #selector(handleSaveAction), for: .touchUpInside)
        }
        
        // MARK: - UI Setup (Sắp xếp layout cơ bản)
        private func setupBaseUI() {
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            
            let stackView = UIStackView(arrangedSubviews: [
                titleLabel, recipeImageView,
                createSectionLabel("Recipe Name"), nameTextField,
                createSectionLabel("Category"), categorySegment,
                createSectionLabel("Duration (minutes)"), durationTextField,
                createSectionLabel("Difficulty Level"), difficultySegment,
                createSectionLabel("Rating"), ratingSegment,
                createSectionLabel("Ingredients"), ingredientsTextView,
                createSectionLabel("Steps"), stepsTextView,
                saveButton
            ])
            
            stackView.axis = .vertical
            stackView.spacing = 15
            stackView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                
                recipeImageView.heightAnchor.constraint(equalToConstant: 200),
                ingredientsTextView.heightAnchor.constraint(equalToConstant: 100),
                stepsTextView.heightAnchor.constraint(equalToConstant: 120),
                saveButton.heightAnchor.constraint(equalToConstant: 55)
            ])
        }
        
        private func createSectionLabel(_ text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textColor = .darkGray
            return label
        }


        func selectedCategory() -> String {
            categorySegment.titleForSegment(at: categorySegment.selectedSegmentIndex) ?? "Breakfast"
        }

        func selectedDifficulty() -> String {
            difficultySegment.titleForSegment(at: difficultySegment.selectedSegmentIndex) ?? "Easy"
        }

        func selectedRating() -> Double {
            Double(ratingSegment.selectedSegmentIndex + 1)
        }

        func parsedIngredients(recipeId: Int = 0) -> [Ingredient] {
            ingredientsTextView.text
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .enumerated()
                .map { index, line in
                    Ingredient(id: index + 1, recipeId: recipeId, name: line, quantity: nil)
                }
        }

        func parsedSteps(recipeId: Int = 0) -> [RecipeStep] {
            stepsTextView.text
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .enumerated()
                .map { index, line in
                    RecipeStep(id: index + 1, recipeId: recipeId, stepNumber: index + 1, description: line)
                }
        }

        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        // MARK: - Handlers
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }

        @objc func handleSelectPhoto() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                recipeImageView.image = editedImage
            }
            dismiss(animated: true)
        }
        
        // Hàm này sẽ được "Con" ghi đè logic (Override)
        @objc func handleSaveAction() {
            // Class con sẽ viết logic lưu ở đây
        }
    }
// MARK: - Tiện ích mở rộng
extension UITextField {
    static func createStandard(placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.keyboardType = keyboard
        tf.translatesAutoresizingMaskIntoConstraints = false // Để dùng Auto Layout
        return tf
    }
}

extension UITextView {
    static func createStandard() -> UITextView {
        let tv = UITextView()
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.font = .systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }
}
