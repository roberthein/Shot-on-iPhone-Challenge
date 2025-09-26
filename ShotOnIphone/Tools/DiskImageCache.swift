import Foundation
import SwiftUI
import UIKit
import CryptoKit

enum DiskImageCache {
    private static let folderURL: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = base.appendingPathComponent("CachedAsyncImage", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    private static func key(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func fileURL(for url: URL) -> URL {
        folderURL.appendingPathComponent(key(for: url)).appendingPathExtension("img")
    }

    static func loadSync(url: URL) -> UIImage? {
        let path = fileURL(for: url)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }

    static func save(_ data: Data, for url: URL) {
        let path = fileURL(for: url)
        try? data.write(to: path, options: [.atomic])
    }

    static func storeFromNetworkIfMissing(_ url: URL) async {
        let path = fileURL(for: url)
        if FileManager.default.fileExists(atPath: path.path) { return }

        if let cached = URLCache.shared.cachedResponse(for: URLRequest(url: url))?.data {
            save(cached, for: url)
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            save(data, for: url)
        } catch {
        }
    }
}
