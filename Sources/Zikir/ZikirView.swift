import SwiftData
import SwiftUI

private let PHRASES = ["Sübhanallah", "Elhamdülillah", "Allahuekber", "Estağfirullah"]
private let DEFAULT_TARGET = 33

struct ZikirView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCounts: [DhikrCount]

    @State private var selectedPhrase = PHRASES[0]
    @State private var target = DEFAULT_TARGET

    private let calendar = Calendar.current

    private var todayRecord: DhikrCount? {
        let today = calendar.startOfDay(for: .now)
        return allCounts.first {
            $0.phrase == selectedPhrase && calendar.isDate($0.date, inSameDayAs: today)
        }
    }

    private var todayCount: Int { todayRecord?.count ?? 0 }

    private var todayTotalAllPhrases: Int {
        let today = calendar.startOfDay(for: .now)
        return allCounts
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.count }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Zikir")
                .font(ZumrutFont.display(20))
                .foregroundColor(ZumrutColors.ink)
                .padding(.top, 12)

            phraseChips

            ring
                .padding(.top, 8)
                .onTapGesture { increment() }

            HStack(spacing: 10) {
                statChip(value: "\(todayTotalAllPhrases)", label: "bugün toplam", tint: ZumrutColors.teal)
                statChip(value: "\(target)", label: "hedef", tint: ZumrutColors.gold)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            HStack(spacing: 10) {
                Button("Sıfırla") { reset() }
                    .buttonStyle(GhostButtonStyle())
                Button("Hedefi Değiştir") { target = target == 33 ? 99 : (target == 99 ? 100 : 33) }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZumrutColors.paper)
    }

    private var phraseChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PHRASES, id: \.self) { phrase in
                    Text(phrase)
                        .font(ZumrutFont.mono(12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedPhrase == phrase ? ZumrutColors.teal : Color.clear)
                        .foregroundColor(selectedPhrase == phrase ? .white : ZumrutColors.muted)
                        .overlay(
                            Capsule().strokeBorder(selectedPhrase == phrase ? Color.clear : ZumrutColors.line)
                        )
                        .clipShape(Capsule())
                        .onTapGesture { selectedPhrase = phrase }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var progress: Double {
        guard target > 0 else { return 0 }
        let raw: Double = Double(todayCount) / Double(target)
        return min(raw, 1.0)
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(ZumrutColors.line, lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ZumrutColors.teal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(todayCount)")
                    .font(ZumrutFont.display(40))
                    .foregroundColor(ZumrutColors.ink)
                Text("/ \(target)")
                    .font(ZumrutFont.mono(12))
                    .foregroundColor(ZumrutColors.muted)
            }
        }
        .frame(width: 180, height: 180)
        .contentShape(Circle())
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

    private func increment() {
        let today = calendar.startOfDay(for: .now)
        if let record = todayRecord {
            record.count += 1
        } else {
            modelContext.insert(DhikrCount(date: today, phrase: selectedPhrase, count: 1))
        }
    }

    private func reset() {
        if let record = todayRecord {
            modelContext.delete(record)
        }
    }
}

private struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZumrutFont.body(12, weight: .semibold))
            .foregroundColor(ZumrutColors.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(ZumrutColors.teal))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
