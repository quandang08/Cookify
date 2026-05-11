//
//  AddRecipeController.swift
//  Cooktify
//
//  Created by user on 2026/05/11.
//

import UIKit

class AddRecipeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let titleLabel: UILabel = {
            let lbl = UILabel()
            lbl.text = "Add New Recipe"
            lbl.font = .boldSystemFont(ofSize: 28)
            lbl.textColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
            lbl.translatesAutoresizingMaskIntoConstraints = false
            return lbl
        }()

        let recipeImageView: UIImageView = {
            let iv = UIImageView()
            iv.backgroundColor = .systemGray6
            iv.contentMode = .scaleAspectFill
            iv.layer.cornerRadius = 20
            iv.clipsToBounds = true
            iv.isUserInteractionEnabled = true // Để nhấn vào chọn ảnh được
            iv.image = UIImage(systemName: "photo.on.rectangle.angled")
            iv.tintColor = .systemGray3
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()

        let nameTextField: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Recipe Name"
            tf.borderStyle = .roundedRect
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()

    let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Recipe", for: .normal)
        btn.backgroundColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
            
        // Thêm sự kiện nhấn vào ảnh để chọn ảnh
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
        recipeImageView.addGestureRecognizer(tap)
            
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    }
    private func setupUI() {
            view.addSubview(titleLabel)
            view.addSubview(recipeImageView)
            view.addSubview(nameTextField)
            view.addSubview(saveButton)

            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                recipeImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                recipeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                recipeImageView.widthAnchor.constraint(equalToConstant: 250),
                recipeImageView.heightAnchor.constraint(equalToConstant: 200),

                nameTextField.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 30),
                nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                nameTextField.heightAnchor.constraint(equalToConstant: 50),

                saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                saveButton.heightAnchor.constraint(equalToConstant: 55)
            ])
        }
    // MARK: - Handlers
        @objc private func handleSelectPhoto() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }

        @objc private func handleSave() {
            print("Backend Quân: Đang chuẩn bị lưu món \(nameTextField.text ?? "")...")
            dismiss(animated: true) // Lưu xong thì đóng màn hình
        }

        // Delegate khi chọn ảnh xong
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                recipeImageView.image = editedImage
            }
            dismiss(animated: true)
        }
}
