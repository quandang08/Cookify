//
//  Recipe.swift
//  Cooktify
//
//  Created by user on 2026/05/06.
//

struct Recipe: Identifiable {
    let id: Int
    let name: String
    let image: String?
    let category: String?
    let duration: Int  //30 mins
    let difficulty: String  // Easy, Medium, Hard
    let averageRating: Double
    let createdAt: String
}
