//
//  RecipeDetailController.swift
//  Cooktify
//
//  Created by user on 2026/05/08.
//

import UIKit

class RecipeDetailController: UIViewController {
    var currentRecipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
            // 1. Khởi tạo Alert
            let alert = UIAlertController(
                title: "Delete Recipe?",
                message: "Are you sure you want to delete this recipe? This action cannot be undone.",
                preferredStyle: .alert
            )
            
            // 2. Hành động Xoá (Màu đỏ)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.handleDeleteLogic()
            }
            
            // 3. Hành động Huỷ
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // Thêm các nút vào bảng thông báo
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            // Hiển thị Alert lên màn hình
            present(alert, animated: true, completion: nil)
        }
    @IBAction func editButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Khởi tạo màn hình Edit
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditRecipeController") as? EditRecipeController else { return }
        
        // Truyền dữ liệu từ Detail sang Edit
        editVC.recipeToEdit = self.currentRecipe // "self.currentRecipe" là món ăn đang hiện ở Detail
        
        self.present(editVC, animated: true)
    }
        
        private func handleDeleteLogic() {
            print("Backend Quân: Đang thực thi xóa dữ liệu...")
            // Sau khi xóa xong, quay lại màn hình danh sách (Home)
            navigationController?.popViewController(animated: true)
        }
    
    @IBAction func ingredientTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

}
