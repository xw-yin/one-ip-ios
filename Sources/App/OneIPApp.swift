import SwiftUI

@main
struct OneIPApp: App {
    @StateObject private var appSettings = AppSettings.shared
    
    var body: some Scene {
        WindowGroup {
            TabContainerView()
                .environmentObject(appSettings)
                .preferredColorScheme(colorScheme)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appSettings.appearanceMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
