import SwiftData
import SwiftUI

// Root of the Takip tab: a weekly namaz overview (with kaza cells, per the
// mockup) plus quick stats and links into the fuller Zikir/Oruç/Zekât/Fitre/
// Bağışlarım screens, so those don't each need their own tab.
struct TakipHubView: View {
    @Query(sort: \PrayerRecord.date, order: .reverse) private var allPrayerRecords: [PrayerRecord]
    @Query private var allFastingRecords: [FastingRecord]
    @Query private var allDhikrCounts: [DhikrCount]

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                weekGrid
                legend
                statChips
                linksSection
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ZumrutColors.paper)
        .navigationTitle("Takip")
    }

    // MARK: - Weekly grid

    private var weekDates: [Date] {
        let today = calendar.startOfDay(for: .now)
        let weekday = calendar.component(.weekday, from: today) // Sunday = 1 ... Saturday = 7
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private var weekGrid: some View {
        let today = calendar.startOfDay(for: .now)
        let dates = weekDates
        return Grid(horizontalSpacing: 6, verticalSpacing: 8) {
            GridRow {
                Text("")
                ForEach(dates, id: \.self) { date in
                    Text(dayLetter(for: date))
                        .font(ZumrutFont.mono(10))
                        .foregroundColor(ZumrutColors.muted)
                }
            }
            ForEach(PrayerKey.allCases, id: \.self) { key in
                GridRow {
                    Text(abbreviation(for: key))
                        .font(ZumrutFont.mono(11))
                        .foregroundColor(ZumrutColors.muted)
                    ForEach(dates, id: \.self) { date in
                        cell(key: key, day: date, isFuture: date > today)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func cell(key: PrayerKey, day: Date, isFuture: Bool) -> some View {
        let status = recordStatus(key: key, day: day)
        return RoundedRectangle(cornerRadius: 4)
            .fill(status == .done ? ZumrutColors.teal : (status == .kaza ? ZumrutColors.goldTint : Color.clear))
            .frame(height: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        status == .kaza ? ZumrutColors.gold : ZumrutColors.line,
                        style: StrokeStyle(lineWidth: 1.5, dash: isFuture && status == .none ? [3, 2] : [])
                    )
            )
    }

    private enum CellStatus { case none, done, kaza }

    private func recordStatus(key: PrayerKey, day: Date) -> CellStatus {
        guard let record = allPrayerRecords.first(where: {
            $0.prayerKey == key.rawValue && calendar.isDate($0.date, inSameDayAs: day)
        }) else { return .none }
        return record.isKaza ? .kaza : .done
    }

    private func abbreviation(for key: PrayerKey) -> String {
        switch key {
        case .Fajr: return "Sb"
        case .Dhuhr: return "Öğ"
        case .Asr: return "İk"
        case .Maghrib: return "Ak"
        case .Isha: return "Yt"
        }
    }

    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 14) {
                legendItem(color: ZumrutColors.teal, label: "Kılındı")
                legendItem(color: ZumrutColors.goldTint, borderColor: ZumrutColors.gold, label: "Kaza")
                legendItem(color: .clear, borderColor: ZumrutColors.line, label: "Henüz gelmedi")
            }

            Text("Ana Sayfa'daki namaz listesine dokunarak işaretlersiniz: bir dokunuş kılındı, ikinci dokunuş kaza olarak kaydeder.")
                .font(ZumrutFont.mono(10))
                .foregroundColor(ZumrutColors.muted)
        }
        .padding(.horizontal, 20)
    }

    private func legendItem(color: Color, borderColor: Color? = nil, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(borderColor ?? .clear, lineWidth: 1.5))
            Text(label).font(ZumrutFont.mono(10)).foregroundColor(ZumrutColors.muted)
        }
    }

    // MARK: - Stats

    private var kazaCount: Int { allPrayerRecords.filter(\.isKaza).count }

    private var fastingThisMonth: Int {
        allFastingRecords.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }.count
    }

    private var dhikrToday: Int {
        allDhikrCounts
            .filter { calendar.isDate($0.date, inSameDayAs: .now) }
            .reduce(0) { $0 + $1.count }
    }

    private var statChips: some View {
        HStack(spacing: 10) {
            statChip(value: "\(kazaCount)", label: "kaza namazı", tint: ZumrutColors.gold)
            statChip(value: "\(fastingThisMonth)", label: "oruç günü", tint: ZumrutColors.teal)
            statChip(value: "\(dhikrToday)", label: "zikir bugün", tint: ZumrutColors.gold)
        }
        .padding(.horizontal, 20)
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

    // MARK: - Links

    private var linksSection: some View {
        VStack(spacing: 0) {
            hubLink(title: "Zikir", systemImage: "circle.grid.cross") { ZikirView() }
            hubLink(title: "Oruç", systemImage: "moon.stars") { OrucView() }
            hubLink(title: "Zekât", systemImage: "banknote") { ZakatView() }
            hubLink(title: "Fitre", systemImage: "gift") { FitreView() }
            hubLink(title: "Bağışlarım", systemImage: "chart.bar") { DonationsView() }
        }
        .padding(.horizontal, 20)
    }

    private func hubLink<Destination: View>(title: String, systemImage: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(ZumrutColors.teal)
                    .frame(width: 22)
                Text(title)
                    .font(ZumrutFont.body(14))
                    .foregroundColor(ZumrutColors.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(ZumrutColors.muted)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle().fill(ZumrutColors.line).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
