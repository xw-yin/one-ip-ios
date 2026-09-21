import SwiftUI

public struct RDAPSection: View {
    @Binding public var query: String
    public let result: RDAPResult?
    public let isLoading: Bool
    public var onSearch: (() -> Void)? = nil
    
    public init(query: Binding<String>, result: RDAPResult?, isLoading: Bool, onSearch: (() -> Void)? = nil) {
        self._query = query
        self.result = result
        self.isLoading = isLoading
        self.onSearch = onSearch
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search Input Row
            HStack(spacing: 8) {
                TextField("输入域名 / IP / AS 号 (例如 apple.com)", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 14, design: .monospaced))
                    .submitLabel(.search)
                    .onSubmit { onSearch?() }
                
                Button {
                    onSearch?()
                } label: {
                    if isLoading {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Text("查询")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(LinearGradient.brandFlow, in: Capsule())
                    }
                }
            }
            .liquidGlassCard(cornerRadius: 16, padding: 12)
            
            // Result View
            if let res = result {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.brandCyan)
                        Text(res.name ?? res.query)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                        Spacer()
                        Text(res.source)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Divider().opacity(0.3)
                    
                    VStack(spacing: 8) {
                        if let registrar = res.registrar {
                            BGPDetailRow(label: "注册服务商", value: registrar)
                            Divider().opacity(0.3)
                        }
                        if let regDate = res.registrationDate {
                            BGPDetailRow(label: "注册时间", value: String(regDate.prefix(10)))
                            Divider().opacity(0.3)
                        }
                        if let expDate = res.expirationDate {
                            BGPDetailRow(label: "过期时间", value: String(expDate.prefix(10)))
                            Divider().opacity(0.3)
                        }
                        if let ns = res.nameservers, !ns.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DNS 服务器")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                ForEach(ns, id: \.self) { server in
                                    Text(server)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.brandCyan)
                                }
                            }
                        }
                    }
                }
                .liquidGlassCard(cornerRadius: 18, padding: 16)
            }
        }
    }
}
