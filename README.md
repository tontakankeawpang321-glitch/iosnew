# Game Token Boy

A SwiftUI iOS app that searches and plays web games in a built-in WebView. The first game is Flappy 2; games added in the app are saved on the device. The library shows 10 games per page and requests an AdMob interstitial when moving between pages.

## Open in Xcode

Open `GameTokenBoy.xcodeproj` on a Mac with Xcode. Xcode resolves the Google Mobile Ads SDK package automatically. Select an iOS simulator or connected iPhone and run the `GameTokenBoy` scheme.

This workspace is Windows-based and does not include Xcode, so the project cannot be built or run here.

## AdMob setup

The project currently uses Google's test iOS app ID and test interstitial unit ID. Keep these test IDs during development. Before release, replace `GADApplicationIdentifier` in `GameTokenBoy/Info.plist` and `adUnitID` in `GameTokenBoy/InterstitialAdManager.swift` with IDs from your AdMob account, then review Google's consent and privacy requirements for the markets where the app will be distributed.

## Add games

Use the plus button in the app and enter a game name and HTTPS URL. An HTTPS cover-image URL is optional. Games are stored locally on the device.
