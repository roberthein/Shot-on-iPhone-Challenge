import Foundation
import SwiftUI
import UIKit

public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var cachedUIImage: UIImage?

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder = { ProgressView() }
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder

        if let url, let img = DiskImageCache.loadSync(url: url) {
            _cachedUIImage = State(initialValue: img)
        } else {
            _cachedUIImage = State(initialValue: nil)
        }
    }

    public var body: some View {
        Group {
            if let ui = cachedUIImage {
                content(Image(uiImage: ui))
            } else if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        content(image)
                            .task(id: url) {
                                await DiskImageCache.storeFromNetworkIfMissing(url)
                            }
                    case .empty:
                        placeholder()
                    case .failure:
                        placeholder()
                    @unknown default:
                        placeholder()
                    }
                }
            } else {
                placeholder()
            }
        }
    }
}

public extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?) {
        self.init(url: url, content: { $0 }, placeholder: { ProgressView() })
    }
}
