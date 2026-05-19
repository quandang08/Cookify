//
//  RecipeDatabase.swift
//  Cooktify
//
//  Created by user on 2026/05/16.
//

import Foundation
import SQLite

final class RecipeDatabase {
    static let shared = RecipeDatabase()
    private let db = DatabaseManager.shared.db

    // MARK: - Tables
    private let recipes = Table("recipes")
    private let ingredients = Table("ingredients")
    private let steps = Table("steps")
    private let recentlyViewed = Table("recently_viewed")

    // MARK: - recipes columns
    private let recipeId = Expression<Int>("id")
    private let recipeName = Expression<String>("name")
    private let recipeImage = Expression<String?>("image")
    private let recipeCategory = Expression<String?>("category")
    private let recipeDuration = Expression<Int?>("duration")
    private let recipeDifficulty = Expression<String?>("difficulty")
    private let recipeRating = Expression<Double?>("rating")
    private let recipeIsFavorite = Expression<Bool>("is_favorite")
    private let recipeCreatedAt = Expression<String?>("created_at")

    // MARK: - ingredients columns
    private let ingredientId = Expression<Int>("id")
    private let ingredientRecipeId = Expression<Int>("recipe_id")
    private let ingredientName = Expression<String>("name")
    private let ingredientQuantity = Expression<String?>("quantity")

    // MARK: - steps columns
    private let stepId = Expression<Int>("id")
    private let stepRecipeId = Expression<Int>("recipe_id")
    private let stepNumber = Expression<Int>("step_number")
    private let stepDescription = Expression<String>("description")

    // MARK: - recently_viewed columns
    private let viewedId = Expression<Int>("id")
    private let viewedRecipeId = Expression<Int>("recipe_id")
    private let viewedAt = Expression<String>("viewed_at")

    private init() {
        createTables()
    }

    // MARK: - Schema
    func createTables() {
        guard let db else { return }

        do {
            try db.run(recipes.create(ifNotExists: true) { table in
                table.column(recipeId, primaryKey: .autoincrement)
                table.column(recipeName)
                table.column(recipeImage)
                table.column(recipeCategory)
                table.column(recipeDuration)
                table.column(recipeDifficulty)
                table.column(recipeRating)
                table.column(recipeIsFavorite, defaultValue: false)
                table.column(recipeCreatedAt)
            })

            try db.run(ingredients.create(ifNotExists: true) { table in
                table.column(ingredientId, primaryKey: .autoincrement)
                table.column(ingredientRecipeId)
                table.column(ingredientName)
                table.column(ingredientQuantity)
            })

            try db.run(steps.create(ifNotExists: true) { table in
                table.column(stepId, primaryKey: .autoincrement)
                table.column(stepRecipeId)
                table.column(stepNumber)
                table.column(stepDescription)
            })

            try db.run(recentlyViewed.create(ifNotExists: true) { table in
                table.column(viewedId, primaryKey: .autoincrement)
                table.column(viewedRecipeId)
                table.column(viewedAt)
            })

            migrateRecipesTableIfNeeded()

            print("Backend Quân: Đã khởi tạo database Cooktify với 4 bảng")
        } catch {
            print("Lỗi tạo bảng database: \(error)")
        }
    }


    private func migrateRecipesTableIfNeeded() {
        guard let db else { return }

        do {
            let existingColumns = try db.prepare("PRAGMA table_info(recipes)").compactMap { row -> String? in
                row[1] as? String
            }

            if !existingColumns.contains("image") {
                try db.run("ALTER TABLE recipes ADD COLUMN image TEXT")
            }

            if !existingColumns.contains("category") {
                try db.run("ALTER TABLE recipes ADD COLUMN category TEXT")
            }

            if !existingColumns.contains("duration") {
                try db.run("ALTER TABLE recipes ADD COLUMN duration INTEGER")
            }

            if !existingColumns.contains("difficulty") {
                try db.run("ALTER TABLE recipes ADD COLUMN difficulty TEXT")
            }

            if !existingColumns.contains("rating") {
                try db.run("ALTER TABLE recipes ADD COLUMN rating REAL")
            }

            if !existingColumns.contains("is_favorite") {
                try db.run("ALTER TABLE recipes ADD COLUMN is_favorite INTEGER DEFAULT 0")
            }

            if !existingColumns.contains("created_at") {
                try db.run("ALTER TABLE recipes ADD COLUMN created_at TEXT")
            }

            // Nếu import từ database cũ có bảng ratings/favorites riêng, copy dữ liệu về recipes cho schema mới.
            try? db.run("UPDATE recipes SET rating = (SELECT rating FROM ratings WHERE ratings.recipe_id = recipes.id LIMIT 1) WHERE rating IS NULL")
            try? db.run("UPDATE recipes SET is_favorite = 1 WHERE id IN (SELECT recipe_id FROM favorites)")
        } catch {
            print("Lỗi migrateRecipesTableIfNeeded: \(error)")
        }
    }

    // MARK: - Read
    func fetchAllRecipes() -> [Recipe] {
        guard let db else { return [] }

        do {
            return try db.prepare(recipes.order(recipeId.desc)).map { row in
                makeRecipe(from: row)
            }
        } catch {
            print("Lỗi fetchAllRecipes: \(error)")
            return []
        }
    }

    func fetchFavoriteRecipes() -> [Recipe] {
        guard let db else { return [] }

        do {
            return try db.prepare(recipes.filter(recipeIsFavorite == true).order(recipeId.desc)).map { row in
                makeRecipe(from: row)
            }
        } catch {
            print("Lỗi fetchFavoriteRecipes: \(error)")
            return []
        }
    }

    func fetchRecipes(category: String) -> [Recipe] {
        guard let db else { return [] }
        guard category.lowercased() != "all" else { return fetchAllRecipes() }

        do {
            return try db.prepare(recipes.filter(recipeCategory == category).order(recipeId.desc)).map { row in
                makeRecipe(from: row)
            }
        } catch {
            print("Lỗi fetchRecipes(category:): \(error)")
            return []
        }
    }

    func searchRecipes(keyword: String) -> [Recipe] {
        guard let db else { return [] }
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return fetchAllRecipes() }

        do {
            let query = recipes
                .filter(recipeName.like("%\(trimmedKeyword)%") || recipeCategory.like("%\(trimmedKeyword)%"))
                .order(recipeId.desc)

            return try db.prepare(query).map { row in
                makeRecipe(from: row)
            }
        } catch {
            print("Lỗi searchRecipes: \(error)")
            return []
        }
    }

    func fetchRecipeDetail(id idValue: Int) -> Recipe? {
        guard let db else { return nil }

        do {
            guard let row = try db.pluck(recipes.filter(recipeId == idValue)) else { return nil }
            var recipe = makeRecipe(from: row)
            recipe.ingredients = fetchIngredients(recipeId: idValue)
            recipe.steps = fetchSteps(recipeId: idValue)
            return recipe
        } catch {
            print("Lỗi fetchRecipeDetail: \(error)")
            return nil
        }
    }

    func fetchRecentlyViewedRecipes(limit: Int = 10) -> [Recipe] {
        guard let db else { return [] }

        do {
            let rows = try db.prepare(recentlyViewed.order(viewedId.desc).limit(limit))
            return rows.compactMap { row in
                fetchRecipeDetail(id: row[viewedRecipeId])
            }
        } catch {
            print("Lỗi fetchRecentlyViewedRecipes: \(error)")
            return []
        }
    }

    // MARK: - Create
    @discardableResult
    func createRecipe(_ recipe: Recipe) -> Int? {
        guard let db else { return nil }

        do {
            let insert = recipes.insert(
                recipeName <- recipe.name,
                recipeImage <- recipe.image,
                recipeCategory <- recipe.category,
                recipeDuration <- recipe.duration,
                recipeDifficulty <- recipe.difficulty,
                recipeRating <- recipe.rating,
                recipeIsFavorite <- recipe.isFavorite,
                recipeCreatedAt <- recipe.createdAt
            )

            let newRecipeId = Int(try db.run(insert))
            replaceIngredients(recipeId: newRecipeId, ingredients: recipe.ingredients)
            replaceSteps(recipeId: newRecipeId, steps: recipe.steps)
            return newRecipeId
        } catch {
            print("Lỗi createRecipe: \(error)")
            return nil
        }
    }

    // MARK: - Update
    func updateRecipe(_ recipe: Recipe) {
        guard let db else { return }

        do {
            let target = recipes.filter(recipeId == recipe.id)
            try db.run(target.update(
                recipeName <- recipe.name,
                recipeImage <- recipe.image,
                recipeCategory <- recipe.category,
                recipeDuration <- recipe.duration,
                recipeDifficulty <- recipe.difficulty,
                recipeRating <- recipe.rating,
                recipeIsFavorite <- recipe.isFavorite,
                recipeCreatedAt <- recipe.createdAt
            ))

            replaceIngredients(recipeId: recipe.id, ingredients: recipe.ingredients)
            replaceSteps(recipeId: recipe.id, steps: recipe.steps)
        } catch {
            print("Lỗi updateRecipe: \(error)")
        }
    }

    func toggleFavorite(recipeId idValue: Int) {
        guard let db else { return }

        do {
            guard let row = try db.pluck(recipes.filter(recipeId == idValue)) else { return }
            let currentValue = row[recipeIsFavorite]
            try db.run(recipes.filter(recipeId == idValue).update(recipeIsFavorite <- !currentValue))
        } catch {
            print("Lỗi toggleFavorite: \(error)")
        }
    }

    func addRecentlyViewed(recipeId idValue: Int) {
        guard let db else { return }

        do {
            try db.run(recentlyViewed.insert(
                viewedRecipeId <- idValue,
                viewedAt <- currentTimestampString()
            ))
        } catch {
            print("Lỗi addRecentlyViewed: \(error)")
        }
    }

    // MARK: - Delete
    func deleteRecipe(id idValue: Int) {
        guard let db else { return }

        do {
            try db.run(ingredients.filter(ingredientRecipeId == idValue).delete())
            try db.run(steps.filter(stepRecipeId == idValue).delete())
            try db.run(recentlyViewed.filter(viewedRecipeId == idValue).delete())
            try db.run(recipes.filter(recipeId == idValue).delete())
        } catch {
            print("Lỗi deleteRecipe: \(error)")
        }
    }

    // MARK: - Private helpers
    private func fetchIngredients(recipeId idValue: Int) -> [Ingredient] {
        guard let db else { return [] }

        do {
            return try db.prepare(ingredients.filter(ingredientRecipeId == idValue).order(ingredientId.asc)).map { row in
                Ingredient(
                    id: row[ingredientId],
                    recipeId: row[ingredientRecipeId],
                    name: row[ingredientName],
                    quantity: row[ingredientQuantity]
                )
            }
        } catch {
            print("Lỗi fetchIngredients: \(error)")
            return []
        }
    }

    private func fetchSteps(recipeId idValue: Int) -> [RecipeStep] {
        guard let db else { return [] }

        do {
            return try db.prepare(steps.filter(stepRecipeId == idValue).order(stepNumber.asc)).map { row in
                RecipeStep(
                    id: row[stepId],
                    recipeId: row[stepRecipeId],
                    stepNumber: row[stepNumber],
                    description: row[stepDescription]
                )
            }
        } catch {
            print("Lỗi fetchSteps: \(error)")
            return []
        }
    }

    private func replaceIngredients(recipeId idValue: Int, ingredients newIngredients: [Ingredient]) {
        guard let db else { return }

        do {
            try db.run(ingredients.filter(ingredientRecipeId == idValue).delete())

            for ingredient in newIngredients where !ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try db.run(ingredients.insert(
                    ingredientRecipeId <- idValue,
                    ingredientName <- ingredient.name,
                    ingredientQuantity <- ingredient.quantity
                ))
            }
        } catch {
            print("Lỗi replaceIngredients: \(error)")
        }
    }

    private func replaceSteps(recipeId idValue: Int, steps newSteps: [RecipeStep]) {
        guard let db else { return }

        do {
            try db.run(steps.filter(stepRecipeId == idValue).delete())

            for (index, step) in newSteps.enumerated() where !step.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try db.run(steps.insert(
                    stepRecipeId <- idValue,
                    stepNumber <- index + 1,
                    stepDescription <- step.description
                ))
            }
        } catch {
            print("Lỗi replaceSteps: \(error)")
        }
    }

    private func makeRecipe(from row: Row) -> Recipe {
        Recipe(
            id: row[recipeId],
            name: row[recipeName],
            image: row[recipeImage],
            category: row[recipeCategory],
            duration: row[recipeDuration] ?? 0,
            rating: row[recipeRating],
            difficulty: row[recipeDifficulty] ?? "Easy",
            isFavorite: row[recipeIsFavorite],
            createdAt: row[recipeCreatedAt] ?? Recipe.currentDateString()
        )
    }

    private func currentTimestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
