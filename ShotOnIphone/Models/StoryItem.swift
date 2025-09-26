import Foundation

public struct StoryItem: Identifiable, Sendable, Equatable {
    public let id: Int
    public let story: Story
    public let seed: String
    public let ratio: Double = .random(in: (0.6 ... 0.9))

    public var imageId: Int {
        story.id
    }

    public var imageURLPaths: [String] {
        [
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Alex-Jiang-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Elizabeth-Scarrott-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-LieAdi-Darmawan-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Robert-Glaser-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Darren-Soh-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Nikita-Yarosh-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot_oniPhone_ikuchika_aoyama_011221_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_ShotoniPhone-bahar_aknc_011921_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_ShotoniPhone_ikuchika_aoyama_011221_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_ShotoniPhone_joe_jirasak_panpiansilp_011221_inline.jpg.large_2x.jpg",

            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Andrew-Griswold-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Daniel-Olah_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Marco-Colletta_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Prajwal-Chougule_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Tom-Reeves_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Guido-Cassanelli_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Hojisan_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Jirasak-Panpiansin_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Ashley-Lee_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-macro-Abhik-Mondal_inline.jpg.large_2x.jpg",

            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot-On-iPhone-Challenge-Winners_Mitsun-Soni_03032020_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot-On-iPhone-Challenge-Winners_Rustam-Shagimordanov_03032020_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot-On-iPhone-Challenge-Winners_Konstantin-Chalabov_03032020_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot-On-iPhone-Challenge-Winners_Ruben-P-Bescos_03032020_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot-On-iPhone-Challenge-Winners_Yu-Zhang_03032020_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_ShotoniPhone_abdullah_shaijie_011221_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple_Shot-On-iPhone-Challenge-Winners_Andrei-Manuilov_03032020_inline.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Blake-Marvin-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Dina-Alfasi-02262019_big.jpg.large_2x.jpg",
            "https://www.apple.com/newsroom/images/product/iphone/lifestyle/Apple-Shot-on-iPhone-Challenge-winners-Bernard-Antolin-02262019_big.jpg.large_2x.jpg",
        ]
    }

    public func imageURL() -> URL? {
        let path = imageURLPaths[id - 1]
        return URL(string: path)
    }
}
