# One IP - iOS 原生版本 (SwiftUI)

基于开源项目 [zhihui-hu/one-ip](https://github.com/zhihui-hu/one-ip.git) 的 iOS 原生版本，使用 **SwiftUI** 构建，遵循 **iOS 27 前瞻设计规范（Spatial Liquid Glass 材质、拟物光影与触觉沉浸系统）**。

---

## 🌟 功能特性

- 🌐 **双出口 IP 探测**：国内出口（网易 CDN / 字节跳动）与海外公网出口（ip.sb / ipwho.is / ip-api）独立检测。
- 🛡️ **动态纯净度信誉环 (Reputation Gauge)**：0–100 动态流光评分环，自动识别住宅 IP、机房、移动网络、VPN、代理、Tor 及滥用标记。
- 🗺️ **MapKit 原生定位雷达**：高精度地理坐标呈现与雷达脉冲光波。
- ⚡ **主流平台出口分流预览**：快速探测 Cloudflare、GitHub、Google、Apple、ChatGPT、Claude、Discord 等路由出口与延迟。
- 🔍 **IP 深度探针**：任意 IPv4 / IPv6 / 域名查询、多源对比、BGP 广播网段与 PTR 查询。
- 🤖 **AI 服务矩阵**：覆盖 ChatGPT、Claude、Gemini、Grok、Perplexity、DeepSeek、通义千问、Kimi 的连通性与 Cloudflare Trace 出口检测。
- 🩺 **网络诊断工具箱**：DNS 泄漏测试、全球 CDN 边缘节点 POP 识别、本地网卡与 WebRTC 接口安全、六大洲全球 Ping 探针、WHOIS / RDAP 实时注册查询。
- ⚙️ **服务状态与偏好**：全球云服务可用性监控、支持自定义 Cloudflare Worker 后端、IP 掩码脱敏与深浅模式无缝切换。

---

## 🛠️ 构建与运行

### 环境要求
- macOS Sonoma / Sequoia
- Xcode 15.0+ (推荐最新版本)
- iOS 17.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (可选，用于重新生成工程)

### 快速开始
1. 克隆本仓库：
   ```bash
   git clone https://github.com/xw-yin/one-ip-ios.git
   cd one-ip-ios
   ```
2. 生成或直接打开工程：
   ```bash
   # 如需重新生成工程
   xcodegen generate

   # 打开 Xcode
   open OneIP.xcodeproj
   ```
3. 在 Xcode 中选择目标真机或模拟器，点击 **Run (⌘R)** 即可。

---

## 🚀 CI/CD 自动化构建与发布

本项目已配置 GitHub Actions 自动化流程（采用 **版本号 + Build 构建号** 命名规范）：

- **版本规范**：`v{VERSION}+b{BUILD_NUMBER}`，并在构建时自动注入 `Info.plist` 的 `CFBundleShortVersionString` 与 `CFBundleVersion`。
- **发布方式**：
  - 推送 Tag（如 `v1.0.0`）时自动编译、打包 `.ipa` 并创建 GitHub Release。
  - 在 GitHub Actions 页面通过 **Run workflow** 手动输入版本号一键构建发布。

---

## 📄 开源许可

本项目基于 [MIT 许可证](LICENSE) 开源。特别致谢原项目 [zhihui-hu/one-ip](https://github.com/zhihui-hu/one-ip.git)。
