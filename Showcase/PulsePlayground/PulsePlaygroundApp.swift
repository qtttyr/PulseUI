import SwiftUI
import PulseUI

@main
struct PulsePlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            GalleryRootView()
                .pulseTheme(pulse)
                .pulseToast()
        }
    }
}