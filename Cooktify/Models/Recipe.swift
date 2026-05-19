//
//  Recipe.swift
//  Cooktify
//
//  Created by user on 2026/05/06.
//

import Foundation

struct Ingredient: Identifiable {
    let id: Int
    let recipeId: Int
    var name: String
    var quantity: String?
}

struct RecipeStep: Identifiable {
    let id: Int
    let recipeId: Int
    var stepNumber: Int
    var description: String
}

struct RecentlyViewedRecipe: Identifiable {
    let id: Int
    let recipeId: Int
    let viewedAt: String
}

struct Recipe: Identifiable {
    let id: Int
    var name: String
    var image: String?
    var category: String?
    var duration: Int
    var rating: Double?
    var difficulty: String
    var isFavorite: Bool
    var createdAt: String
    var ingredients: [Ingredient]
    var steps: [RecipeStep]

    init(
        id: Int,
        name: String,
        image: String? = nil,
        category: String? = nil,
        duration: Int = 0,
        rating: Double? = nil,
        difficulty: String = "Easy",
        isFavorite: Bool = false,
        createdAt: String = Recipe.currentDateString(),
        ingredients: [Ingredient] = [],
        steps: [RecipeStep] = []
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.category = category
        self.duration = duration
        self.rating = rating
        self.difficulty = difficulty
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.ingredients = ingredients
        self.steps = steps
    }

    static func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
