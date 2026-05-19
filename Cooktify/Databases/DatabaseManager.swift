//
//  DatabaseManager.swift
//  Cooktify
//
//  Created by user on 2026/05/14.
//

import Foundation
import SQLite

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let databaseFileName = "Cookify"
    private let databaseFileExtension = "db"

    public private(set) var db: Connection?

    private init() {
        do {
            let databaseURL = try prepareDatabaseFile()
            db = try Connection(databaseURL.path)
            print("Backend Quân: Kết nối Database thành công tại: \(databaseURL.path)")
        } catch {
            print("Lỗi kết nối DB: \(error)")
        }
    }

    private func prepareDatabaseFile() throws -> URL {
        let fileManager = FileManager.default
        let documentsURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let destinationURL = documentsURL.appendingPathComponent("\(databaseFileName).\(databaseFileExtension)")

        // Nếu DB đã được copy sang Documents rồi thì dùng file đó để app có thể ghi/sửa/xóa.
        if fileManager.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }

        // Lần đầu chạy app: copy DB mẫu từ app bundle sang Documents.
        guard let bundleURL = Bundle.main.url(forResource: databaseFileName, withExtension: databaseFileExtension) else {
            print("Không tìm thấy \(databaseFileName).\(databaseFileExtension) trong app bundle. Tạo DB rỗng ở Documents.")
            return destinationURL
        }

        try fileManager.copyItem(at: bundleURL, to: destinationURL)
        print("Backend Quân: Đã copy database mẫu sang Documents")
        return destinationURL
    }
}
