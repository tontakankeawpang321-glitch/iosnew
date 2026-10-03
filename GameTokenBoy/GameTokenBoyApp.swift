import GoogleMobileAds
import SwiftUI

@main
struct GameTokenBoyApp: App {
    @StateObject private var adManager = InterstitialAdManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(adManager)
                .task {
                    MobileAds.shared.start(completionHandler: nil)
                    adManager.load()
                }
        }
    }
}
