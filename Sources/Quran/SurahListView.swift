import SwiftUI

struct SurahListView: View {
    @State private var surahs: [SurahSummary] = []
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let errorMessage {
                Text(errorMessage)
                    .font(ZumrutFont.body(14))
                    .foregroundColor(ZumrutColors.muted)
                    .padding()
            } else if surahs.isEmpty {
                ProgressView().tint(ZumrutColors.teal)
            } else {
                List(surahs) { surah in
                    NavigationLink(value: surah.number) {
                        SurahRow(surah: surah)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Kur'an")
        .navigationDestination(for: Int.self) { number in
            SurahDetailView(surahNumber: number)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink { DualarView() } label: { Label("Dualar", systemImage: "hands.sparkles") }
                    NavigationLink { TilavetView() } label: { Label("Tilavet", systemImage: "waveform") }
                    NavigationLink { PrayerTutorialView() } label: { Label("Namaz Öğretici", systemImage: "figure.mixed.cardio") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            guard surahs.isEmpty else { return }
            do {
                surahs = try await QuranService.fetchSurahList()
            } catch {
                errorMessage = "Sure listesi alınamadı. Tekrar deneyin."
            }
        }
    }
}

private struct SurahRow: View {
    let surah: SurahSummary

    var body: some View {
        HStack {
            Text("\(surah.number)")
                .font(ZumrutFont.mono(12))
                .foregroundColor(ZumrutColors.muted)
                .frame(width: 28, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(surah.englishName)
                    .font(ZumrutFont.body(15, weight: .semibold))
                    .foregroundColor(ZumrutColors.ink)
                Text("\(surah.revelationTypeTurkish) · \(surah.numberOfAyahs) Ayet")
                    .font(ZumrutFont.mono(11))
                    .foregroundColor(ZumrutColors.muted)
            }
            Spacer()
            Text(surah.name)
                .font(.system(size: 17))
                .foregroundColor(ZumrutColors.teal)
        }
        .padding(.vertical, 4)
    }
}
