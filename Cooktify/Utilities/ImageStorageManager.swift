//
//  ImageStorageManager.swift
//  Cooktify
//
//  Handles recipe images saved by users into the app Documents folder.
//

import UIKit

final class ImageStorageManager {
    static let shared = ImageStorageManager()

    private let folderName = "RecipeImages"

    private init() {}

    @discardableResult
    func saveImage(_ image: UIImage) -> String? {
        let processedImage = image.croppedToRecipeAspectRatio().resizedForRecipeStorage()
        guard let data = processedImage.jpegData(compressionQuality: 0.82) else { return nil }

        do {
            let folderURL = try imagesFolderURL()
            let fileName = "recipe_\(UUID().uuidString).jpg"
            let fileURL = folderURL.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            print("Lỗi saveImage: \(error)")
            return nil
        }
    }

    func loadImage(named imageName: String?) -> UIImage? {
        guard let imageName, !imageName.isEmpty else { return nil }

        if let storedImage = loadStoredImage(named: imageName) {
            return storedImage
        }

        if let assetImage = UIImage(named: imageName) {
            return assetImage
        }

        return nil
    }

    func deleteImage(named imageName: String?) {
        guard let imageName, !imageName.isEmpty else { return }

        do {
            let fileURL = try imagesFolderURL().appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Lỗi deleteImage: \(error)")
        }
    }

    private func loadStoredImage(named imageName: String) -> UIImage? {
        do {
            let fileURL = try imagesFolderURL().appendingPathComponent(imageName)
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
            return UIImage(contentsOfFile: fileURL.path)
        } catch {
            print("Lỗi loadStoredImage: \(error)")
            return nil
        }
    }

    private func imagesFolderURL() throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let folderURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        return folderURL
    }
}


private extension UIImage {
    /// Crop ảnh về tỉ lệ gần với card recipe để ảnh lên Home/Detail không bị méo hoặc lệch bố cục.
    func croppedToRecipeAspectRatio(targetRatio: CGFloat = 4.0 / 3.0) -> UIImage {
        let imageRatio = size.width / size.height
        var cropRect = CGRect(origin: .zero, size: size)

        if imageRatio > targetRatio {
            let newWidth = size.height * targetRatio
            cropRect.origin.x = (size.width - newWidth) / 2
            cropRect.size.width = newWidth
        } else if imageRatio < targetRatio {
            let newHeight = size.width / targetRatio
            cropRect.origin.y = (size.height - newHeight) / 2
            cropRect.size.height = newHeight
        }

        guard let cgImage = cgImage?.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }

    /// Resize để ảnh lưu local vừa đủ sắc nét nhưng không quá nặng.
    func resizedForRecipeStorage(maxWidth: CGFloat = 1200) -> UIImage {
        guard size.width > maxWidth else { return self }

        let scaleRatio = maxWidth / size.width
        let targetSize = CGSize(width: maxWidth, height: size.height * scaleRatio)
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
