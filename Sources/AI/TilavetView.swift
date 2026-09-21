import SwiftUI

struct TilavetView: View {
    @EnvironmentObject private var store: StoreManager

    @StateObject private var recorder = AudioRecorderService()
    @State private var ayahs: [Ayah] = []
    @State private var selectedIndex = 0
    @State private var isProcessing = false
    @State private var matchFlags: [Bool]?
    @State private var errorMessage: String?

    private var currentAyah: Ayah? {
        ayahs.indices.contains(selectedIndex) ? ayahs[selectedIndex] : nil
    }

    var body: some View {
        if store.isPremium {
            content
        } else {
            PremiumLockedView(
                title: "Tilavet Premium'a Özel",
                message: "Kıraatinizi kelime kelime kontrol eden Tilavet özelliğini kullanmak için Premium'a geçin."
            )
        }
    }

    private var content: some View {
        NavigationStack {
            VStack(spacing: 14) {
                if ayahs.isEmpty {
                    Spacer()
                    ProgressView().tint(ZumrutColors.teal)
                    Spacer()
                } else {
                    Picker("Ayet", selection: $selectedIndex) {
                        ForEach(ayahs.indices, id: \.self) { index in
                            Text("\(index + 1)").tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .onChange(of: selectedIndex) { matchFlags = nil }

                    ScrollView {
                        if let flags = matchFlags, let currentAyah {
                            coloredAyahText(original: currentAyah.text, flags: flags)
                                .font(.system(size: 22))
                                .multilineTextAlignment(.trailing)
                                .environment(\.layoutDirection, .rightToLeft)
                                .padding(.horizontal, 24)

                            Text(String(format: "%%%.0f kelime eşleşti", WordMatcher.accuracy(flags) * 100))
                                .font(ZumrutFont.display(16))
                                .foregroundColor(ZumrutColors.teal)
                                .padding(.top, 10)
                        } else if let currentAyah {
                            Text(currentAyah.text)
                                .font(.system(size: 22))
                                .multilineTextAlignment(.trailing)
                                .environment(\.layoutDirection, .rightToLeft)
                                .padding(.horizontal, 24)
                        }
                    }

                    Spacer()

                    micButton

                    if isProcessing {
                        Text("İşleniyor...").font(ZumrutFont.mono(11)).foregroundColor(ZumrutColors.muted)
                    }
                    if let errorMessage {
                        Text(errorMessage).font(ZumrutFont.body(12)).foregroundColor(ZumrutColors.gold)
                    }

                    Text("Söylediğiniz kelimeleri metinle karşılaştırır — mahreç/tecvid kalitesini değerlendirmez, bir kelime kontrolüdür.")
                        .font(ZumrutFont.mono(9))
                        .foregroundColor(ZumrutColors.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 16)
                }
            }
            .navigationTitle("Tilavet")
            .background(ZumrutColors.paper)
            .task { await loadFatiha() }
        }
    }

    private var micButton: some View {
        Button {
            Task { await toggleRecording() }
        } label: {
            Circle()
                .fill(recorder.isRecording ? ZumrutColors.gold : ZumrutColors.teal)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 22))
                )
        }
        .disabled(isProcessing)
    }

    private func coloredAyahText(original: String, flags: [Bool]) -> Text {
        let words = original.split(separator: " ").map(String.init)
        return words.enumerated().reduce(Text("")) { partial, item in
            let (index, word) = item
            let matched = index < flags.count ? flags[index] : true
            let piece = Text(word + " ").foregroundColor(matched ? ZumrutColors.teal : ZumrutColors.gold)
            return partial + piece
        }
    }

    private func toggleRecording() async {
        if recorder.isRecording {
            guard let url = recorder.stopRecording() else { return }
            await process(fileURL: url)
        } else {
            let granted = await recorder.requestPermission()
            guard granted else {
                errorMessage = "Mikrofon izni gerekli."
                return
            }
            matchFlags = nil
            errorMessage = nil
            recorder.startRecording()
        }
    }

    private func process(fileURL: URL) async {
        guard let currentAyah else { return }
        isProcessing = true
        defer { isProcessing = false }
        do {
            let transcribed = try await TranscriptionService.transcribe(audioFileURL: fileURL)
            matchFlags = WordMatcher.matchFlags(expected: currentAyah.text, transcribed: transcribed)
        } catch {
            errorMessage = "Ses işlenemedi. Tekrar deneyin."
        }
    }

    private func loadFatiha() async {
        do {
            let detail = try await QuranService.fetchSurah(number: 1)
            ayahs = detail.arabicAyahs
        } catch {
            errorMessage = "Sure alınamadı."
        }
    }
}
