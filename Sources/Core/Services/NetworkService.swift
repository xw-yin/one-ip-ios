import Foundation

public enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(Int)
    case parseError
    case timeout
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的请求地址"
        case .serverError(let code): return "服务器返回错误 (\(code))"
        case .parseError: return "数据解析失败"
        case .timeout: return "请求超时"
        case .cancelled: return "请求已取消"
        }
    }
}

public struct TraceResult: Sendable {
    public let ip: String
    public let countryCode: String?
    public let colo: String?
    public let rawMap: [String: String]
}

public final class NetworkService: Sendable {
    public static let shared = NetworkService()
    
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8.0
        config.timeoutIntervalForResource = 12.0
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config)
    }
    
    public func fetchString(from urlString: String, timeout: TimeInterval = 6.0) async throws -> (content: String, latencyMs: Int) {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        let start = ContinuousClock().now
        let (data, response) = try await session.data(for: request)
        let duration = start.duration(to: ContinuousClock().now)
        let latencyMs = Int(duration.components.seconds * 1000 + duration.components.attoseconds / 1_000_000_000_000_000)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(-1)
        }
        guard (200...399).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        guard let string = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
            throw NetworkError.parseError
        }
        return (string, max(1, latencyMs))
    }
    
    public func fetchJSON<T: Decodable>(_ type: T.Type, from urlString: String, timeout: TimeInterval = 6.0) async throws -> T {
        let (string, _) = try await fetchString(from: urlString, timeout: timeout)
        guard let data = string.data(using: .utf8) else { throw NetworkError.parseError }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }
    
    public func fetchHeaders(from urlString: String, timeout: TimeInterval = 5.0) async throws -> [String: String] {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = timeout
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return [:] }
        var headers: [String: String] = [:]
        for (key, value) in httpResponse.allHeaderFields {
            headers[String(describing: key).lowercased()] = String(describing: value)
        }
        return headers
    }
    
    public func fetchTrace(domain: String, timeout: TimeInterval = 4.0) async throws -> TraceResult {
        let url = "https://\(domain)/cdn-cgi/trace"
        let (text, _) = try await fetchString(from: url, timeout: timeout)
        return parseTrace(text: text)
    }
    
    public func parseTrace(text: String) -> TraceResult {
        var map: [String: String] = [:]
        for line in text.components(separatedBy: "\n") {
            let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
            if parts.count == 2 {
                map[parts[0].trimmingCharacters(in: .whitespaces)] = parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        let ip = map["ip"] ?? ""
        let loc = map["loc"]
        let colo = map["colo"]
        return TraceResult(ip: ip, countryCode: loc, colo: colo, rawMap: map)
    }
    
    public func probe(urlString: String, timeout: TimeInterval = 4.0) async -> (isReachable: Bool, latencyMs: Int?) {
        guard let url = URL(string: urlString) else { return (false, nil) }
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.httpMethod = "GET"
        let start = ContinuousClock().now
        do {
            let (_, response) = try await session.data(for: request)
            let duration = start.duration(to: ContinuousClock().now)
            let latencyMs = Int(duration.components.seconds * 1000 + duration.components.attoseconds / 1_000_000_000_000_000)
            if let http = response as? HTTPURLResponse, (200...499).contains(http.statusCode) {
                return (true, max(1, latencyMs))
            }
            return (false, nil)
        } catch {
            return (false, nil)
        }
    }
}
