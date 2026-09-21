import CoreLocation
import SwiftData
import SwiftUI

struct HomeView: View {
    @StateObject private var location = LocationProvider()
    @State private var timings: PrayerTimings?
    @State private var errorMessage: String?
    @State private var isShowingCachedTimings = false
    @State private var now = Date()
    @AppStorage("ezanBildirimleriAcik") private var notificationsEnabled = false

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PrayerRecord.date, order: .reverse) private var allPrayerRecords: [PrayerRecord]

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    private let calendar = Calendar.current

    var body: some View {
        Group {
            if let errorMessage {
                Text(errorMessage)
                    .font(ZumrutFont.body(14))
                    .foregroundColor(ZumrutColors.muted)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if let timings {
                content(timings: timings)
            } else {
                ProgressView().tint(ZumrutColors.teal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZumrutColors.paper)
        .task { await load() }
        .onReceive(timer) { now = $0 }
    }

    @ViewBuilder
    private func content(timings: PrayerTimings) -> some View {
        let next = nextPrayer(timings: timings, now: now)
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if isShowingCachedTimings {
                    offlineBadge
                }
                nextPrayerCard(next: next)
                prayerList(timings: timings, next: next)
                prayerStatusHint
                streakRow
                if let upcoming = HijriCalendarService.nextImportantDay(from: now) {
                    upcomingDayRow(upcoming)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("Zümrüt")
                .font(ZumrutFont.display(20))
                .foregroundColor(ZumrutColors.teal)
            Spacer()
            NavigationLink { QiblaView() } label: {
                Image(systemName: "location.north.line")
                    .font(.system(size: 16))
                    .foregroundColor(ZumrutColors.muted)
            }
            Button { toggleNotifications() } label: {
                Image(systemName: notificationsEnabled ? "bell.fill" : "bell")
                    .font(.system(size: 16))
                    .foregroundColor(notificationsEnabled ? ZumrutColors.teal : ZumrutColors.muted)
            }
            VStack(alignment: .trailing, spacing: 2) {
                Text(now.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR"))))
                    .font(ZumrutFont.mono(12))
                    .foregroundColor(ZumrutColors.muted)
                Text(HijriCalendarService.hijriDateString(for: now))
                    .font(ZumrutFont.mono(11))
                    .foregroundColor(ZumrutColors.gold)
            }
        }
        .padding(.horizontal, 20)
    }

    private var offlineBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
            Text("Çevrimdışı — son bilinen vakitler gösteriliyor")
        }
        .font(ZumrutFont.mono(11))
        .foregroundColor(ZumrutColors.gold)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(ZumrutColors.goldTint)
        .clipShape(Capsule())
        .padding(.horizontal, 20)
    }

    private var streakRow: some View {
        let streak = PrayerStreak.currentStreak(records: allPrayerRecords, today: now, calendar: calendar)
        return HStack {
            Text("Namaz Streak")
                .font(ZumrutFont.body(13, weight: .semibold))
                .foregroundColor(ZumrutColors.ink)
            Spacer()
            Text(streak == 0 ? "Henüz başlamadı" : "\(streak) gün")
                .font(ZumrutFont.mono(12))
                .foregroundColor(ZumrutColors.teal)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(ZumrutColors.tealTint)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func upcomingDayRow(_ upcoming: HijriCalendarService.UpcomingDay) -> some View {
        HStack {
            Text(upcoming.name)
                .font(ZumrutFont.body(13, weight: .semibold))
                .foregroundColor(ZumrutColors.ink)
            Spacer()
            Text(upcoming.daysUntil == 0 ? "Bugün" : "\(upcoming.daysUntil) gün sonra")
                .font(ZumrutFont.mono(11))
                .foregroundColor(ZumrutColors.gold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(ZumrutColors.goldTint)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
    }

    private func nextPrayerCard(next: NextPrayer) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SONRAKİ NAMAZ")
                .font(ZumrutFont.mono(11))
                .foregroundColor(.white.opacity(0.75))
            HStack(alignment: .lastTextBaseline) {
                Text(next.key.displayName)
                    .font(ZumrutFont.display(26))
                    .foregroundColor(.white)
                Spacer()
                Text(next.countdownText)
                    .font(ZumrutFont.mono(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(ZumrutColors.teal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private func prayerList(timings: PrayerTimings, next: NextPrayer) -> some View {
        let currentTime = currentTimeString()
        let todayStart = calendar.startOfDay(for: now)
        return VStack(spacing: 0) {
            ForEach(PrayerKey.allCases, id: \.self) { key in
                let isFuture = key.time(from: timings) >= currentTime || key == next.key
                let status = recordStatus(key: key, day: todayStart)
                HStack(spacing: 10) {
                    Text(key.displayName)
                        .font(ZumrutFont.body(15))
                        .foregroundColor(ZumrutColors.ink)
                    Spacer()
                    Text(key.time(from: timings))
                        .font(ZumrutFont.mono(13))
                        .foregroundColor(ZumrutColors.muted)
                    ZStack {
                        Circle().fill(status == .kaza ? ZumrutColors.goldTint : (status == .done ? ZumrutColors.teal : Color.clear))
                        Circle().strokeBorder(
                            status == .done ? ZumrutColors.teal : (status == .kaza ? ZumrutColors.gold : (isFuture ? ZumrutColors.line : ZumrutColors.gold)),
                            lineWidth: 1.5
                        )
                        if status == .done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 22, height: 22)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .opacity(isFuture ? 0.5 : 1)
                .onTapGesture {
                    guard !isFuture else { return }
                    advanceStatus(key: key, day: todayStart)
                }
                .overlay(alignment: .bottom) {
                    Rectangle().fill(ZumrutColors.line).frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // Explains the tap cycle inline, next to the list it describes — the
    // Takip tab's grid shows the same "kaza" state but can't explain how to
    // set it, since marking only happens here.
    private var prayerStatusHint: some View {
        HStack(spacing: 14) {
            hintItem(color: ZumrutColors.teal, label: "1 dokunuş: kılındı")
            hintItem(color: ZumrutColors.gold, label: "2 dokunuş: kaza")
        }
        .padding(.horizontal, 20)
    }

    private func hintItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(ZumrutFont.mono(10)).foregroundColor(ZumrutColors.muted)
        }
    }

    enum RecordStatus { case none, done, kaza }

    private func recordStatus(key: PrayerKey, day: Date) -> RecordStatus {
        guard let record = allPrayerRecords.first(where: {
            $0.prayerKey == key.rawValue && calendar.isDate($0.date, inSameDayAs: day)
        }) else { return .none }
        return record.isKaza ? .kaza : .done
    }

    // Tapping a past/current prayer cycles: none -> done -> kaza -> none,
    // so a prayer missed on time can be marked for makeup without a
    // separate screen.
    private func advanceStatus(key: PrayerKey, day: Date) {
        let existing = allPrayerRecords.first {
            $0.prayerKey == key.rawValue && calendar.isDate($0.date, inSameDayAs: day)
        }
        switch existing {
        case .none:
            modelContext.insert(PrayerRecord(date: day, prayerKey: key.rawValue))
        case .some(let record) where !record.isKaza:
            record.isKaza = true
        case .some(let record):
            modelContext.delete(record)
        }
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: now)
    }

    private func load() async {
        location.requestLocation()
        // Give Core Location a brief moment to resolve; fall back to Istanbul otherwise.
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let coordinate = location.coordinate ?? LocationProvider.fallback
        do {
            let today = try await PrayerTimesService.fetchTimings(latitude: coordinate.latitude, longitude: coordinate.longitude)
            timings = today
            isShowingCachedTimings = false
            PrayerTimesService.cacheTimings(today, for: now, coordinate: coordinate)
            if notificationsEnabled {
                await scheduleNotifications(coordinate: coordinate, todayTimings: today)
            }
        } catch {
            if let cached = PrayerTimesService.cachedTimings(for: now, coordinate: coordinate) {
                timings = cached
                isShowingCachedTimings = true
            } else {
                errorMessage = "Namaz vakitleri alınamadı. İnternet bağlantınızı kontrol edin."
            }
        }
    }

    private func scheduleNotifications(coordinate: CLLocationCoordinate2D, todayTimings: PrayerTimings) async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        do {
            let tomorrowTimings = try await PrayerTimesService.fetchTimings(
                latitude: coordinate.latitude, longitude: coordinate.longitude, date: tomorrow
            )
            NotificationService.scheduleForNext48Hours(todayTimings: todayTimings, tomorrowTimings: tomorrowTimings)
        } catch {
            // Notifications are a nice-to-have; a failed fetch here shouldn't affect the main screen.
        }
    }

    private func toggleNotifications() {
        Task {
            if notificationsEnabled {
                NotificationService.cancelAll()
                notificationsEnabled = false
            } else {
                let granted = await NotificationService.requestAuthorization()
                guard granted else { return }
                notificationsEnabled = true
                if let timings {
                    let coordinate = location.coordinate ?? LocationProvider.fallback
                    await scheduleNotifications(coordinate: coordinate, todayTimings: timings)
                }
            }
        }
    }
}
