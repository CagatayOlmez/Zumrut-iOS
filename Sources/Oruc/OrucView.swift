import SwiftData
import SwiftUI

struct OrucView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingRecord.date) private var allRecords: [FastingRecord]

    @State private var visibleMonth = Date()
    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Oruç Takvimi")
                    .font(ZumrutFont.display(20))
                    .foregroundColor(ZumrutColors.ink)
                Spacer()
                Text(monthTitle)
                    .font(ZumrutFont.mono(12))
                    .foregroundColor(ZumrutColors.muted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            weekdayHeader
            calendarGrid

            HStack(spacing: 10) {
                statChip(value: "\(countThisMonth)", label: "bu ay", tint: ZumrutColors.teal)
                statChip(value: "\(allRecords.count)", label: "toplam", tint: ZumrutColors.gold)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ZumrutColors.paper)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM y"
        return formatter.string(from: visibleMonth)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["P", "S", "Ç", "P", "C", "C", "P"], id: \.self) { label in
                Text(label)
                    .font(ZumrutFont.mono(11))
                    .foregroundColor(ZumrutColors.muted)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: visibleMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        // Convert Sunday-first (1...7) to Monday-first (0...6) leading blanks.
        let leadingBlanks = (firstWeekday + 5) % 7
        let dayCount = calendar.range(of: .day, in: .month, for: visibleMonth)?.count ?? 0

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<dayCount {
            if let date = calendar.date(byAdding: .day, value: offset, to: monthInterval.start) {
                days.append(date)
            }
        }
        return days
    }

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 30)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func dayCell(_ day: Date) -> some View {
        let isFasted = allRecords.contains { calendar.isDate($0.date, inSameDayAs: day) }
        let isFuture = day > calendar.startOfDay(for: .now)
        let isToday = calendar.isDateInToday(day)

        return Text("\(calendar.component(.day, from: day))")
            .font(ZumrutFont.mono(11))
            .foregroundColor(isFasted ? .white : (isToday ? ZumrutColors.gold : ZumrutColors.muted))
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .background(isFasted ? ZumrutColors.teal : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(isToday && !isFasted ? ZumrutColors.gold : ZumrutColors.line, lineWidth: isToday ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .opacity(isFuture ? 0.4 : 1)
            .onTapGesture {
                guard !isFuture else { return }
                toggle(day: day)
            }
    }

    private var countThisMonth: Int {
        guard let monthInterval = calendar.dateInterval(of: .month, for: visibleMonth) else { return 0 }
        return allRecords.filter { monthInterval.contains($0.date) }.count
    }

    private func toggle(day: Date) {
        let dayStart = calendar.startOfDay(for: day)
        if let existing = allRecords.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FastingRecord(date: dayStart))
        }
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
