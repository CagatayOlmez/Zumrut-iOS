import SwiftUI

// Abstract, non-figurative pictograms (head + torso + legs as simple shapes) —
// deliberately schematic, like a diagram, not a figurative depiction of a person.
struct PosturePictogram: View {
    let posture: Posture
    var color: Color = ZumrutColors.teal

    var body: some View {
        ZStack {
            switch posture {
            case .standing:
                head.offset(y: -38)
                torso(height: 44).offset(y: -6)
                legs(height: 36).offset(y: 34)
            case .bowing:
                head.offset(x: 30, y: -6)
                torso(height: 44)
                    .rotationEffect(.degrees(85), anchor: .bottom)
                    .offset(x: 6, y: 10)
                legs(height: 34).offset(y: 34)
            case .prostrate:
                head.offset(x: 34, y: 22)
                torso(height: 40)
                    .rotationEffect(.degrees(90), anchor: .leading)
                    .offset(x: -6, y: 22)
                legs(height: 30).offset(x: -30, y: 22)
            case .sitting:
                head.offset(y: -14)
                torso(height: 28).offset(y: 6)
                legs(height: 16).offset(y: 30)
            }
        }
        .frame(width: 120, height: 110)
    }

    private var head: some View {
        Circle().fill(color).frame(width: 18, height: 18)
    }

    private func torso(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 6, height: height)
    }

    private func legs(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 6, height: height)
    }
}
