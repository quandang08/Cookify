import UIKit

class AddRecipeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Add New Recipe"
        lbl.font = .boldSystemFont(ofSize: 28)
        lbl.textColor = UIColor(red: 26/255, green: 71/255, blue: 51/255, alpha: 1.0)
        return lbl
    }()

    private let recipeImageView: UIImageView = {
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

    private let nameTextField = UITextField.createStandard(placeholder: "Recipe Name")
    private let durationTextField = UITextField.createStandard(placeholder: "Duration (mins)", keyboard: .numberPad)
    
    private let categorySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Breakfast", "Lunch", "Dinner"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let difficultySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Easy", "Medium", "Hard"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let ingredientsTextView = UITextView.createStandard()
    private let stepsTextView = UITextView.createStandard()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Recipe", for: .normal)
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
        setupUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
        recipeImageView.addGestureRecognizer(tap)
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            recipeImageView,
            createSectionLabel("Recipe Name"), nameTextField,
            createSectionLabel("Category"), categorySegment,
            createSectionLabel("Duration (minutes)"), durationTextField,
            createSectionLabel("Difficulty Level"), difficultySegment,
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
            nameTextField.heightAnchor.constraint(equalToConstant: 45),
            durationTextField.heightAnchor.constraint(equalToConstant: 45),
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

    // MARK: - Handlers
    @objc private func handleSelectPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func handleSave() {
        // Gom dữ liệu vào Object (Mô phỏng Backend logic)
        let name = nameTextField.text ?? ""
        let duration = Int(durationTextField.text ?? "0") ?? 0
        let category = categorySegment.titleForSegment(at: categorySegment.selectedSegmentIndex) ?? ""
        let level = difficultySegment.titleForSegment(at: difficultySegment.selectedSegmentIndex) ?? ""
        
        print("--- SAVING RECIPE ---")
        print("Name: \(name), Time: \(duration)m, Cate: \(category), Level: \(level)")
        print("Ingredients: \(ingredientsTextView.text ?? "")")
        
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            recipeImageView.image = editedImage
        }
        dismiss(animated: true)
    }
}

// MARK: - Tiện ích mở rộng để Code sạch hơn
extension UITextField {
    static func createStandard(placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.keyboardType = keyboard
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
        return tv
    }
}
