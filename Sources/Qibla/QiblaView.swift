import SwiftUI

struct QiblaView: View {
    @StateObject private var compass = CompassProvider()

    private var qiblaBearing: Double? {
        guard let coordinate = compass.coordinate else { return nil }
        return QiblaMath.bearing(from: coordinate, to: QiblaMath.kaaba)
    }

    private var distanceKm: Double? {
        guard let coordinate = compass.coordinate else { return nil }
        return QiblaMath.distanceKm(from: coordinate, to: QiblaMath.kaaba)
    }

    // Rotation applied to the needle so it always points at the Kaaba,
    // regardless of which way the phone itself is facing.
    private var needleRotation: Double {
        guard let qiblaBearing else { return 0 }
        return qiblaBearing - compass.headingDegrees
    }

    private var isAligned: Bool {
        let diff = abs(needleRotation.truncatingRemainder(dividingBy: 360))
        let normalized = diff > 180 ? 360 - diff : diff
        return normalized < 5
    }

    private var needleColor: Color {
        isAligned ? ZumrutColors.teal : ZumrutColors.gold
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Kıble")
                .font(ZumrutFont.display(20))
                .foregroundColor(ZumrutColors.ink)
                .padding(.top, 12)

            if compass.coordinate == nil {
                Spacer()
                ProgressView().tint(ZumrutColors.teal)
                Text("Konum bekleniyor...")
                    .font(ZumrutFont.body(13))
                    .foregroundColor(ZumrutColors.muted)
                Spacer()
            } else {
                Spacer()
                dial
                Spacer()

                HStack(spacing: 10) {
                    statChip(
                        value: String(format: "%.0f°", qiblaBearing ?? 0),
                        label: QiblaMath.compassLabel(forDegrees: qiblaBearing ?? 0),
                        tint: ZumrutColors.teal
                    )
                    statChip(value: distanceText, label: "Mekke'ye", tint: ZumrutColors.gold)
                }
                .padding(.horizontal, 20)

                Text(isAligned ? "Kıbleye dönüksünüz" : "Doğru yön için telefonu 8 çizerek kalibre edin.")
                    .font(ZumrutFont.mono(11))
                    .foregroundColor(isAligned ? ZumrutColors.teal : ZumrutColors.muted)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZumrutColors.paper)
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
        .task {
            // If location never resolves (permission denied, Simulator with no
            // location set, etc.), fall back to Istanbul after a short wait.
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if compass.coordinate == nil {
                compass.coordinate = LocationProvider.fallback
            }
        }
    }

    private var distanceText: String {
        guard let distanceKm else { return "—" }
        return String(format: "%.0f km", distanceKm)
    }

    private var dial: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ZumrutColors.tealTint, Color.clear],
                        center: .center, startRadius: 0, endRadius: 100
                    )
                )
            Circle().strokeBorder(ZumrutColors.line, lineWidth: 2)

            cardinalLabel("K", x: 0, y: -84)
            cardinalLabel("G", x: 0, y: 84)
            cardinalLabel("D", x: 84, y: 0)
            cardinalLabel("B", x: -84, y: 0)

            NeedleShape()
                .fill(needleColor)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(needleRotation))

            Circle()
                .fill(ZumrutColors.ink)
                .frame(width: 8, height: 8)
        }
        .frame(width: 200, height: 200)
    }

    private func cardinalLabel(_ text: String, x: CGFloat, y: CGFloat) -> some View {
        Text(text)
            .font(ZumrutFont.mono(13))
            .foregroundColor(ZumrutColors.muted)
            .offset(x: x, y: y)
    }

    private func statChip(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(ZumrutFont.display(17)).foregroundColor(tint)
            Text(label).font(ZumrutFont.mono(10)).foregroundColor(ZumrutColors.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// Draws a small arrowhead-and-shaft needle inside a bounding box whose
// center coincides with the box's own midX/midY — so rotating this view
// with the default .center anchor rotates correctly around the dial's center.
private struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let tipY = rect.minY + 20
        let headHalfWidth: CGFloat = 7
        let headBaseY = tipY + 14

        var path = Path()
        path.move(to: CGPoint(x: midX, y: tipY))
        path.addLine(to: CGPoint(x: midX - headHalfWidth, y: headBaseY))
        path.addLine(to: CGPoint(x: midX + headHalfWidth, y: headBaseY))
        path.closeSubpath()
        path.addRect(CGRect(x: midX - 2, y: headBaseY, width: 4, height: midY - headBaseY))
        return path
    }
}
