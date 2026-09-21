import SwiftUI

struct PrayerTutorialView: View {
    @State private var stepIndex = 0

    private var step: TutorialStep { PrayerTutorial.steps[stepIndex] }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("ADIM \(stepIndex + 1) / \(PrayerTutorial.steps.count)")
                    .font(ZumrutFont.mono(12))
                    .foregroundColor(ZumrutColors.muted)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            PosturePictogram(posture: step.posture)

            Text(step.title)
                .font(ZumrutFont.display(22))
                .foregroundColor(ZumrutColors.ink)

            Text(step.instruction)
                .font(ZumrutFont.body(14))
                .foregroundColor(ZumrutColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            stepDots

            HStack(spacing: 10) {
                if stepIndex > 0 {
                    Button("Önceki") { stepIndex -= 1 }
                        .buttonStyle(GhostStyle())
                }
                Button(stepIndex == PrayerTutorial.steps.count - 1 ? "Baştan Başla" : "Sonraki Adım") {
                    if stepIndex == PrayerTutorial.steps.count - 1 {
                        stepIndex = 0
                    } else {
                        stepIndex += 1
                    }
                }
                .buttonStyle(FilledStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZumrutColors.paper)
    }

    private var stepDots: some View {
        HStack(spacing: 5) {
            ForEach(PrayerTutorial.steps) { s in
                Capsule()
                    .fill(s.id - 1 == stepIndex ? ZumrutColors.teal : ZumrutColors.line)
                    .frame(width: s.id - 1 == stepIndex ? 14 : 5, height: 5)
            }
        }
    }
}

private struct FilledStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZumrutFont.body(14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(ZumrutColors.teal)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private struct GhostStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZumrutFont.body(14, weight: .semibold))
            .foregroundColor(ZumrutColors.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(ZumrutColors.teal))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
