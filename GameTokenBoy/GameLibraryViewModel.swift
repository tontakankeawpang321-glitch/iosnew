import Foundation
import Combine

@MainActor
final class GameLibraryViewModel: ObservableObject {
    @Published private(set) var games: [Game] {
        didSet { saveGames() }
    }

    private let storageKey = "savedGames"
    let pageSize = 10

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedGames = try? JSONDecoder().decode([Game].self, from: data),
           !savedGames.isEmpty {
            games = savedGames
        } else {
            games = [.featured]
        }
    }

    func addGame(name: String, url: URL, coverURL: URL?) {
        games.append(Game(name: name, url: url, coverURL: coverURL))
    }

    func filteredGames(matching searchTerm: String) -> [Game] {
        guard !searchTerm.isEmpty else { return games }
        return games.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }

    func pageCount(for games: [Game]) -> Int {
        max(1, Int(ceil(Double(games.count) / Double(pageSize))))
    }

    func games(onPage page: Int, from games: [Game]) -> [Game] {
        let start = page * pageSize
        guard start < games.count else { return [] }
        return Array(games[start..<min(start + pageSize, games.count)])
    }

    private func saveGames() {
        guard let data = try? JSONEncoder().encode(games) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
