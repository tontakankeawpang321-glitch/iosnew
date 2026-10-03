import SwiftUI

struct ContentView: View {
    @StateObject private var library = GameLibraryViewModel()
    @EnvironmentObject private var adManager: InterstitialAdManager
    @State private var searchText = ""
    @State private var appliedSearch = ""
    @State private var currentPage = 0
    @State private var showingAddGame = false

    private var matchingGames: [Game] {
        library.filteredGames(matching: appliedSearch)
    }

    private var visibleGames: [Game] {
        library.games(onPage: currentPage, from: matchingGames)
    }

    private var pageCount: Int {
        library.pageCount(for: matchingGames)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if matchingGames.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)
                        Text("ไม่พบเกม")
                            .font(.headline)
                        Text("ลองค้นหาด้วยชื่ออื่น")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(visibleGames) { game in
                            NavigationLink(value: game) {
                                GameRow(game: game)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: Game.self) { game in
                        GameDetailView(game: game)
                    }
                }

                if !matchingGames.isEmpty {
                    paginationBar
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Game Token Boy")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGame = true
                    } label: {
                        Label("เพิ่มเกม", systemImage: "plus")
                    }
                    .accessibilityLabel("เพิ่มเกม")
                }
            }
            .sheet(isPresented: $showingAddGame) {
                AddGameView { name, url, coverURL in
                    library.addGame(name: name, url: url, coverURL: coverURL)
                    currentPage = max(0, library.pageCount(for: matchingGames) - 1)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            TextField("ค้นหาชื่อเกม", text: $searchText)
                .submitLabel(.search)
                .onSubmit(applySearch)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(action: applySearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.white)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("ค้นหาเกม")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var paginationBar: some View {
        HStack {
            Button {
                changePage(to: currentPage - 1)
            } label: {
                Label("ก่อนหน้า", systemImage: "chevron.left")
            }
            .disabled(currentPage == 0)

            Spacer()
            Text("\(currentPage + 1) / \(pageCount)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
            Spacer()

            Button {
                changePage(to: currentPage + 1)
            } label: {
                Label("ถัดไป", systemImage: "chevron.right")
                    .labelStyle(.titleAndIcon)
            }
            .disabled(currentPage >= pageCount - 1)
        }
        .buttonStyle(.bordered)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func applySearch() {
        appliedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        currentPage = 0
    }

    private func changePage(to page: Int) {
        guard (0..<pageCount).contains(page) else { return }
        guard let presenter = UIApplication.shared.topViewController else {
            currentPage = page
            return
        }
        adManager.show(from: presenter) {
            currentPage = page
        }
    }
}

private struct GameRow: View {
    let game: Game

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: game.coverURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [Color(red: 0.12, green: 0.64, blue: 0.68), Color(red: 0.10, green: 0.28, blue: 0.36)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "snowflake")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(.white.opacity(0.22))
                        .padding(7)
                    VStack(alignment: .leading, spacing: 3) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 16))
                        Text(game.name.uppercased())
                            .font(.system(size: 9, weight: .heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(7)
                }
            }
            .frame(width: 88, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(game.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("แตะเพื่อเล่น")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "play.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
    }
}

private struct GameDetailView: View {
    let game: Game

    var body: some View {
        GameWebView(url: game.url)
            .navigationTitle(game.name)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
    }
}
