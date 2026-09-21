import SwiftUI
import MapKit

public struct MapCardView: View {
    public let geo: GeoInfo?
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var radarScale: CGFloat = 1.0
    @State private var radarOpacity: Double = 0.8
    
    public init(geo: GeoInfo?) {
        self.geo = geo
    }
    
    private var coordinate: CLLocationCoordinate2D {
        geo?.coordinate ?? CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074) // Default Beijing
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.brandCyan)
                    
                    Text(t("map_view"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if let tz = geo?.timezone {
                    Text(tz)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            
            // Map View Container
            ZStack(alignment: .bottomTrailing) {
                Map(position: $cameraPosition) {
                    Annotation(geo?.city ?? "IP Node", coordinate: coordinate) {
                        ZStack {
                            // Pulsing Radar Ring
                            Circle()
                                .stroke(Color.brandCyan.opacity(radarOpacity), lineWidth: 2)
                                .frame(width: 44, height: 44)
                                .scaleEffect(radarScale)
                            
                            // Core Marker
                            Circle()
                                .fill(LinearGradient.brandFlow)
                                .frame(width: 18, height: 18)
                                .overlay {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2.5)
                                }
                                .shadow(color: Color.brandCyan.opacity(0.8), radius: 6)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onAppear {
                    startRadarAnimation()
                    updateCamera()
                }
                .onChange(of: geo?.latitude) { _, _ in
                    updateCamera()
                }
                
                // Coordinates Overlay
                if let lat = geo?.latitude, let lon = geo?.longitude {
                    Text(String(format: "%.4f, %.4f", lat, lon))
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(8)
                }
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 18)
    }
    
    private func updateCamera() {
        if let coord = geo?.coordinate {
            withAnimation(.easeInOut(duration: 1.0)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
                    )
                )
            }
        }
    }
    
    private func startRadarAnimation() {
        withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
            radarScale = 2.2
            radarOpacity = 0.0
        }
    }
}
