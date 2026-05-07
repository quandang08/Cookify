//
//  ViewController.swift
//  Cooktify
//
//  Created by user on 2026/05/02.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      mainCollectionView.dataSource = self
//      mainCollectionView.delegate = self
        mainCollectionView.showsVerticalScrollIndicator = false
    }
}

