//
//  RecipeDetailController.swift
//  Cooktify
//
//  Created by user on 2026/05/08.
//

import UIKit

class RecipeDetailController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
