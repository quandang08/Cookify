import UIKit

class AddRecipeController: BaseRecipeFormController {
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Add New Recipe"
        saveButton.setTitle("Save Recipe", for: .normal)
    }

    override func handleSaveAction() {
        print("Backend Quân: Đang thực thi logic CREATE...")
        // Viết code POST dữ liệu ở đây
        dismiss(animated: true)
    }
}
