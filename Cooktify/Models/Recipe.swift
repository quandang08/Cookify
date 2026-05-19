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
    var rating: Int?
    let difficulty: String  // Easy, Medium, Hard
    let createdAt: String
}
