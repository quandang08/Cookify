//
//  RecipeDatabase.swift
//  Cooktify
//
//  Created by user on 2026/05/16.
//

import Foundation
import SQLite

class RecipeDatabase {
    static let shared = RecipeDatabase()
    private let db = DatabaseManager.shared.db

    // Định nghĩa bảng và các cột
    private let recipes = Table("recipes")
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let duration = Expression<Int?>("duration")
    private let difficulty = Expression<String?>("difficulty")

    private init() {
        createTable()
    }

    func createTable() {
        guard let db = db else { return }
        do {
            try db.run(recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(duration)
                t.column(difficulty)
            })
            print("Backend Quân: Đã khởi tạo bảng Recipes thành công")
        } catch {
            print("Lỗi tạo bảng: \(error)")
        }
    }
}
