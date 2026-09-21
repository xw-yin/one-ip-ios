import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case zhHans = "zh-Hans"
    case en = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system: return "跟随系统 (System)"
        case .zhHans: return "简体中文"
        case .en: return "English"
        }
    }
}

public final class LocalizationManager: @unchecked Sendable, ObservableObject {
    public static let shared = LocalizationManager()
    
    @AppStorage("app_language") public var language: AppLanguage = .system
    
    public func localized(_ key: String) -> String {
        switch language {
        case .zhHans:
            return LocalizedStrings.zh[key] ?? key
        case .en:
            return LocalizedStrings.en[key] ?? key
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "zh-Hans"
            if preferred.hasPrefix("zh") {
                return LocalizedStrings.zh[key] ?? key
            } else {
                return LocalizedStrings.en[key] ?? key
            }
        }
    }
}

public func t(_ key: String) -> String {
    LocalizationManager.shared.localized(key)
}

private enum LocalizedStrings {
    static let zh: [String: String] = [
        "tab_overview": "概览",
        "tab_lookup": "探针",
        "tab_ai": "AI 矩阵",
        "tab_diagnostics": "网络诊断",
        "tab_settings": "设置",
        
        "overview_title": "One IP",
        "overview_subtitle": "瞬息洞察 IP 纯净底色与风险评级",
        "domestic_ip": "国内出口 IP",
        "global_ip": "公网出口 IP",
        "cleanliness_score": "纯净度得分",
        "score_good": "纯净良好",
        "score_moderate": "中等风险",
        "score_poor": "高危风险",
        "score_unknown": "评级检测中",
        "residential": "家庭住宅",
        "datacenter": "机房数据中心",
        "mobile": "移动蜂窝基站",
        "vpn": "VPN",
        "proxy": "代理节点",
        "tor": "Tor 节点",
        "crawler": "爬虫标记",
        "abuse": "滥用举报",
        
        "quick_split": "主流网站分流预览",
        "map_view": "物理定位地图",
        "copy_ip": "复制 IP",
        "copied": "已复制到剪贴板",
        "refresh": "刷新探针",
        "refreshing": "正在同步最新状态...",
        
        "lookup_title": "IP 深度探针",
        "lookup_placeholder": "输入 IPv4 / IPv6 / 域名 (例如 1.1.1.1)",
        "lookup_button": "深度查询",
        "lookup_history": "历史记录",
        "clear_history": "清空",
        "multi_source": "多源地理位置对比",
        "bgp_info": "BGP 广播与网络拓扑",
        "asn_number": "自治系统 (ASN)",
        "cidr_block": "CIDR 广播块",
        "ptr_record": "反向 DNS (PTR)",
        
        "ai_matrix_title": "AI 服务矩阵",
        "ai_matrix_subtitle": "主流大模型连通性与出口地域阻断探测",
        "ai_status_online": "正常可用",
        "ai_status_blocked": "地区受限",
        "ai_status_error": "连通异常",
        "ai_status_checking": "探测中...",
        
        "diag_title": "网络诊断工具箱",
        "diag_dns_leak": "DNS 出口与泄漏",
        "diag_cdn_nodes": "全球 CDN 边缘节点",
        "diag_interface": "本地网卡与 WebRTC",
        "diag_global_ping": "全球 Ping 探针",
        "diag_rdap": "WHOIS / RDAP 注册档案",
        
        "settings_title": "系统与设置",
        "settings_cloud_status": "全球云基础设施状态",
        "settings_backend": "自定义后端节点 (Worker URL)",
        "settings_haptic": "触觉振动反馈",
        "settings_mask_ip": "隐藏脱敏 IP 地址",
        "settings_language": "显示语言",
        "settings_about": "关于 One IP iOS",
        "settings_version": "版本 1.0 (iOS 27 Spatial)"
    ]
    
    static let en: [String: String] = [
        "tab_overview": "Overview",
        "tab_lookup": "Lookup",
        "tab_ai": "AI Matrix",
        "tab_diagnostics": "Diagnostics",
        "tab_settings": "Settings",
        
        "overview_title": "One IP",
        "overview_subtitle": "Instant IP Cleanliness & Risk Diagnostics",
        "domestic_ip": "Domestic IP",
        "global_ip": "Global Public IP",
        "cleanliness_score": "Trust Score",
        "score_good": "Good Standing",
        "score_moderate": "Moderate Risk",
        "score_poor": "High Risk",
        "score_unknown": "Evaluating...",
        "residential": "Residential",
        "datacenter": "Datacenter",
        "mobile": "Mobile Carrier",
        "vpn": "VPN",
        "proxy": "Proxy Node",
        "tor": "Tor Relay",
        "crawler": "Crawler/Bot",
        "abuse": "Abuse Reported",
        
        "quick_split": "Service Split & Routing",
        "map_view": "Physical Location Map",
        "copy_ip": "Copy IP",
        "copied": "Copied to clipboard",
        "refresh": "Refresh",
        "refreshing": "Synchronizing latest state...",
        
        "lookup_title": "IP Deep Probe",
        "lookup_placeholder": "Enter IPv4 / IPv6 / Domain (e.g. 1.1.1.1)",
        "lookup_button": "Inspect",
        "lookup_history": "History",
        "clear_history": "Clear",
        "multi_source": "Multi-Source Geo Consistency",
        "bgp_info": "BGP Routing & Topology",
        "asn_number": "Autonomous System (ASN)",
        "cidr_block": "CIDR Prefix",
        "ptr_record": "Reverse DNS (PTR)",
        
        "ai_matrix_title": "AI Matrix",
        "ai_matrix_subtitle": "LLM Service Accessibility & Exit Geo Diagnostics",
        "ai_status_online": "Accessible",
        "ai_status_blocked": "Region Blocked",
        "ai_status_error": "Unreachable",
        "ai_status_checking": "Probing...",
        
        "diag_title": "Network Diagnostics",
        "diag_dns_leak": "DNS Leak & Resolvers",
        "diag_cdn_nodes": "Global CDN Edge POPs",
        "diag_interface": "Local Interface & WebRTC",
        "diag_global_ping": "Global Ping Probes",
        "diag_rdap": "WHOIS / RDAP Registry",
        
        "settings_title": "Settings & Status",
        "settings_cloud_status": "Global Cloud Infrastructure",
        "settings_backend": "Custom Worker URL",
        "settings_haptic": "Haptic Feedback",
        "settings_mask_ip": "Mask IP Addresses",
        "settings_language": "Language",
        "settings_about": "About One IP iOS",
        "settings_version": "Version 1.0 (iOS 27 Spatial)"
    ]
}
