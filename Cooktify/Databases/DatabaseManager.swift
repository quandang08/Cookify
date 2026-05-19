//
//  DatabaseManager.swift
//  Cooktify
//
//  Created by user on 2026/05/14.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    public var db: Connection?

    private init() {
        do {
            // 1. Tìm đường dẫn đến thư mục Documents
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
            // 2. Tạo/Mở kết nối đến file db.sqlite
            db = try Connection("\(path)/cooktify.sqlite")
            print("Backend Quân: Kết nối Database thành công tại: \(path)/cooktify.sqlite")
        } catch {
            print("Lỗi kết nối DB: \(error)")
        }
    }
}
