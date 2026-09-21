import SwiftUI

struct SurahDetailView: View {
    let surahNumber: Int
    @State private var detail: SurahDetail?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let errorMessage {
                Text(errorMessage)
                    .font(ZumrutFont.body(14))
                    .foregroundColor(ZumrutColors.muted)
                    .padding()
            } else if let detail {
                content(detail: detail)
            } else {
                ProgressView().tint(ZumrutColors.teal)
            }
        }
        .navigationTitle(detail?.summary.englishName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                detail = try await QuranService.fetchSurah(number: surahNumber)
            } catch {
                if let cached = QuranService.cachedSurah(number: surahNumber) {
                    detail = cached
                } else {
                    errorMessage = "Sure alınamadı. İnternet bağlantınızı kontrol edip tekrar deneyin."
                }
            }
        }
    }

    private func content(detail: SurahDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(detail: detail)
                ForEach(Array(zip(detail.arabicAyahs, detail.turkishAyahs)), id: \.0.id) { arabic, turkish in
                    AyahRow(arabic: arabic, turkish: turkish)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private func header(detail: SurahDetail) -> some View {
        VStack(spacing: 4) {
            Text(detail.summary.name)
                .font(.system(size: 28))
                .foregroundColor(ZumrutColors.teal)
            Text("\(detail.summary.revelationTypeTurkish) · \(detail.summary.numberOfAyahs) Ayet")
                .font(ZumrutFont.mono(12))
                .foregroundColor(ZumrutColors.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }
}

private struct AyahRow: View {
    let arabic: Ayah
    let turkish: Ayah

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(alignment: .top) {
                Spacer()
                Text(arabic.text)
                    .font(.system(size: 24))
                    .multilineTextAlignment(.trailing)
                    .environment(\.layoutDirection, .rightToLeft)
                Text("\(arabic.numberInSurah)")
                    .font(ZumrutFont.mono(10))
                    .foregroundColor(ZumrutColors.teal)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().strokeBorder(ZumrutColors.teal, lineWidth: 1))
            }
            Text(turkish.text)
                .font(ZumrutFont.body(14))
                .foregroundColor(ZumrutColors.muted)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(ZumrutColors.line).frame(height: 1)
        }
    }
}
