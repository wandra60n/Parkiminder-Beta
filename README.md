# Parkiminder-Beta

Project properties:
1. Developed with Xcode 10.3
2. Swift 5
3. iOS SDK v 12.4
4. Google Maps SDK for iOS version: 3.3.0.0
5. User Interface designed for iPhone 8

Make sure to:
1. Obtain your Google Maps API Key, reference: https://developers.google.com/maps/documentation/ios-sdk/start
2. Enable Google Maps Static API, reference: https://developers.google.com/maps/documentation/maps-static/intro
3. Make sure you have Cocoapods installed, reference: - https://guides.cocoapods.org/using/getting-started.html

* for project marking purpose, please contact me (via uni email) to obtain temporary Google Maps API Key, or put your own key otherwise

Before openning the project:
1. Open terminal, from the project directory, run:
    `pod install`
2. Open the project from .xcworkspace extension (not .xcodeproj)
3. Create a new Swift file with any name. Put line below:
    `let GMaps_API_Key = "YOUR_GOOGLE_MAPS_API_KEY_HERE"`
4. Open Main.storyboard file, make sure iPhone 8 is selected in scene size

Running the project:
1. With emulator:
    make sure iPhone 8 is selected as active shceme in iOS Simulators
    some application functionality might be limitted, e.g. camera, gps, marker on map
2. With device:
    setup your device, reference: https://codewithchris.com/deploy-your-app-on-an-iphone/
3. Need dummy reminder records?
    call initiateDummyReminders method from viewDidLoad in ViewController.swift. Put any integer as parameters (e.g. 3, 5, 7)

Icon assets attribution:
- bin icon made by Ionicons from https://www.iconfinder.com/iconsets/ionicons
- bluecar icon made by Freepik from https://www.iconfinder.com/iconsets/navigation-set-arrows-part-two
- camera icon made By Stephen Hutchings in https://www.iconfinder.com/iconsets/typicons-2
- close icon made By Denis Mikhutin in https://www.iconfinder.com/iconsets/navigation-set-arrows-part-two
- menu icon made By John Slater in https://www.iconfinder.com/iconsets/ios-tab-bar
- leftcircle icon and upcircle icon made By Riski Mulia in https://www.iconfinder.com/iconsets/arrow-outline-8
- stopwatch icon made by  PINPOINT.WORLD in https://www.iconfinder.com/iconsets/solid-locations-icon-set
- turnright icon By Wanida Sapsanthitikul in https://www.iconfinder.com/iconsets/arrow3