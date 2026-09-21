import SwiftData
import SwiftUI

struct InfoCardView: View {
    @EnvironmentObject private var contentStore: ContentStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InfoCardReadRecord.date, order: .reverse) private var readRecords: [InfoCardReadRecord]

    @State private var showingArchive = false
    private let calendar = Calendar.current

    private var todayCard: InfoCard { InfoCardLibrary.card(for: .now, in: contentStore.infoCards) }

    private var readStreak: Int {
        var streak = 0
        var day = calendar.startOfDay(for: .now)
        while readRecords.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Bugünün Bilgisi")
                        .font(ZumrutFont.display(18))
                        .foregroundColor(ZumrutColors.ink)
                    Spacer()
                    Text(Date.now.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR"))))
                        .font(ZumrutFont.mono(11))
                        .foregroundColor(ZumrutColors.muted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                card

                HStack {
                    ShareLink(item: "\(todayCard.text)\n— \(todayCard.source)") {
                        Label("Paylaş", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(GhostChipStyle())
                    Spacer()
                }
                .padding(.horizontal, 20)

                VStack(spacing: 4) {
                    if readStreak > 0 {
                        Text("\(readStreak) gün üst üste okudun")
                            .font(ZumrutFont.mono(11))
                            .foregroundColor(ZumrutColors.gold)
                    }
                    Button("Geçmiş Kartlar") { showingArchive = true }
                        .font(ZumrutFont.body(12))
                        .foregroundColor(ZumrutColors.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(ZumrutColors.paper)
            .sheet(isPresented: $showingArchive) {
                ArchiveView(records: readRecords, cards: contentStore.infoCards)
            }
            .onAppear { markReadToday() }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(todayCard.category)
                .font(ZumrutFont.mono(10))
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())

            Text(todayCard.text)
                .font(ZumrutFont.display(17))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(todayCard.source)
                .font(ZumrutFont.mono(11))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(ZumrutColors.teal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private func markReadToday() {
        let today = calendar.startOfDay(for: .now)
        let alreadyRead = readRecords.contains {
            $0.cardId == todayCard.id && calendar.isDate($0.date, inSameDayAs: today)
        }
        guard !alreadyRead else { return }
        modelContext.insert(InfoCardReadRecord(date: today, cardId: todayCard.id))
    }
}

private struct ArchiveView: View {
    let records: [InfoCardReadRecord]
    let cards: [InfoCard]

    var body: some View {
        NavigationStack {
            List(records, id: \.persistentModelID) { record in
                if let info = cards.first(where: { $0.id == record.cardId }) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR"))))
                            .font(ZumrutFont.mono(10))
                            .foregroundColor(ZumrutColors.muted)
                        Text(info.text)
                            .font(ZumrutFont.body(13))
                    }
                }
            }
            .navigationTitle("Geçmiş Kartlar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct GhostChipStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZumrutFont.body(12, weight: .semibold))
            .foregroundColor(ZumrutColors.teal)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(ZumrutColors.teal))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
