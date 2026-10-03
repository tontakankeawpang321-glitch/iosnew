import GoogleMobileAds
import Combine
import UIKit

@MainActor
final class InterstitialAdManager: ObservableObject, FullScreenContentDelegate {
    @Published private(set) var isReady = false

    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"
    private var interstitialAd: InterstitialAd?
    private var onDismiss: (() -> Void)?

    func load() {
        InterstitialAd.load(with: adUnitID, request: Request()) { [weak self] ad, _ in
            DispatchQueue.main.async {
                self?.interstitialAd = ad
                self?.isReady = ad != nil
            }
        }
    }

    func show(from viewController: UIViewController, onDismiss: @escaping () -> Void) {
        guard let interstitialAd else {
            onDismiss()
            return
        }

        self.onDismiss = onDismiss
        interstitialAd.fullScreenContentDelegate = self
        interstitialAd.present(from: viewController)
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        isReady = false
        onDismiss?()
        onDismiss = nil
        load()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitialAd = nil
        isReady = false
        onDismiss?()
        onDismiss = nil
        load()
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        let root = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
