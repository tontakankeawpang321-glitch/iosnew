import Foundation

struct Game: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var url: URL
    var coverURL: URL?

    static let featured = Game(
        name: "Frost Smash",
        url: URL(string: "https://tontakan.github.io/gametokenboy/Flappy2.html")!,
        coverURL: nil
    )
}
