import SwiftUI

public struct TabContainerView: View {
    @State private var selectedTab: Int = 0
    @ObservedObject private var locManager = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            OverviewView()
                .tabItem {
                    Label(t("tab_overview"), systemImage: "shield.lefthalf.filled")
                }
                .tag(0)
            
            IPLookupView()
                .tabItem {
                    Label(t("tab_lookup"), systemImage: "magnifyingglass")
                }
                .tag(1)
            
            AIMatrixView()
                .tabItem {
                    Label(t("tab_ai"), systemImage: "sparkles")
                }
                .tag(2)
            
            DiagnosticsView()
                .tabItem {
                    Label(t("tab_diagnostics"), systemImage: "waveform.path.ecg")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label(t("tab_settings"), systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.brandCyan)
        .onChange(of: selectedTab) { _, _ in
            HapticManager.shared.selection()
        }
    }
}
