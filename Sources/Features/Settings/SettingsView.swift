import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @ObservedObject private var locManager = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Cloud Infrastructure Status
                Section {
                    ForEach(appSettings.cloudServices) { item in
                        HStack(spacing: 12) {
                            SiteIconView(
                                domain: item.domain,
                                fallbackSystemName: item.iconName,
                                size: 18
                            )
                            .frame(width: 28, height: 28)
                            .background(.ultraThinMaterial, in: Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(item.provider)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(item.isOperational ? Color.statusGood : Color.statusModerate)
                                    .frame(width: 7, height: 7)
                                
                                if let lat = item.latencyMs {
                                    Text("\(lat)ms")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Label(t("settings_cloud_status"), systemImage: "server.rack")
                }
                
                // Section 2: Backend Configuration
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(t("settings_backend"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("https://ip.huzhihui.com", text: $appSettings.customWorkerURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 13, design: .monospaced))
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Worker 接口服务", systemImage: "externaldrive.badge.wifi")
                }
                
                // Section 3: App Preferences
                Section {
                    Toggle(t("settings_mask_ip"), isOn: $appSettings.isMaskIPEnabled)
                        .tint(.brandCyan)
                    
                    Toggle(t("settings_haptic"), isOn: $appSettings.isHapticEnabled)
                        .tint(.brandCyan)
                    
                    Picker(t("settings_language"), selection: $locManager.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    
                    Picker("外观风格", selection: $appSettings.appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                } header: {
                    Label("偏好设置", systemImage: "slider.horizontal.3")
                }
                
                // Section 4: About
                Section {
                    HStack {
                        Text("项目架构")
                        Spacer()
                        Text("Swift 6 + SwiftUI (iOS 27)")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    
                    HStack {
                        Text("基于开源项目")
                        Spacer()
                        Text("zhihui-hu/one-ip")
                            .foregroundColor(.brandCyan)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    
                    HStack {
                        Text("授权协议")
                        Spacer()
                        Text("MIT License")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))
                    }
                } header: {
                    Label(t("settings_about"), systemImage: "info.circle")
                }
            }
            .navigationTitle(t("settings_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await appSettings.refreshCloudStatus() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.brandCyan)
                    }
                }
            }
            .task {
                await appSettings.refreshCloudStatus()
            }
        }
    }
}
