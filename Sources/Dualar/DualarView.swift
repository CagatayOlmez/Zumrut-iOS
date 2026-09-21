import SwiftData
import SwiftUI

struct DualarView: View {
    @EnvironmentObject private var contentStore: ContentStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomDua.createdAt, order: .reverse) private var customDuas: [CustomDua]

    @AppStorage("favoriteDuaTitles") private var favoriteTitlesRaw: String = ""
    @State private var selectedCategory: String? = nil
    @State private var showingAddSheet = false

    private var favoriteTitles: Set<String> {
        Set(favoriteTitlesRaw.split(separator: "\u{1}").map(String.init))
    }

    private var categories: [String] {
        var seen: [String] = []
        for dua in contentStore.duas where !seen.contains(dua.category) {
            seen.append(dua.category)
        }
        return seen
    }

    private var filteredStaticDuas: [StaticDua] {
        guard let selectedCategory else { return contentStore.duas }
        return contentStore.duas.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryChips
                List {
                    if !customDuas.isEmpty {
                        Section("Eklediklerim") {
                            ForEach(customDuas) { dua in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dua.title).font(ZumrutFont.body(14, weight: .semibold))
                                    Text(dua.text).font(ZumrutFont.body(12)).foregroundColor(ZumrutColors.muted)
                                }
                            }
                            .onDelete { offsets in
                                for index in offsets { modelContext.delete(customDuas[index]) }
                            }
                        }
                    }
                    Section("Dua Koleksiyonu") {
                        ForEach(filteredStaticDuas) { dua in
                            NavigationLink(value: dua.id) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(dua.title).font(ZumrutFont.body(14, weight: .semibold))
                                        if favoriteTitles.contains(dua.title) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(ZumrutColors.gold)
                                        }
                                    }
                                    Text(dua.arabic)
                                        .font(.system(size: 14))
                                        .foregroundColor(ZumrutColors.muted)
                                        .lineLimit(1)
                                        .environment(\.layoutDirection, .rightToLeft)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Dualar")
            .navigationDestination(for: String.self) { id in
                if let dua = contentStore.duas.first(where: { $0.id == id }) {
                    DuaDetailView(dua: dua, isFavorite: favoriteTitles.contains(dua.title), onToggleFavorite: {
                        toggleFavorite(dua.title)
                    })
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddDuaView()
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "Tümü", isSelected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(categories, id: \.self) { category in
                    chip(title: category, isSelected: selectedCategory == category) { selectedCategory = category }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(ZumrutFont.mono(12))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? ZumrutColors.teal : Color.clear)
            .foregroundColor(isSelected ? .white : ZumrutColors.muted)
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : ZumrutColors.line))
            .clipShape(Capsule())
            .onTapGesture(perform: action)
    }

    private func toggleFavorite(_ title: String) {
        var titles = favoriteTitles
        if titles.contains(title) {
            titles.remove(title)
        } else {
            titles.insert(title)
        }
        favoriteTitlesRaw = titles.joined(separator: "\u{1}")
    }
}

private struct DuaDetailView: View {
    let dua: StaticDua
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    @StateObject private var audio = DuaAudioService()

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 16) {
                Text(dua.arabic)
                    .font(.system(size: 22))
                    .multilineTextAlignment(.trailing)
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(dua.source)
                    .font(ZumrutFont.mono(11))
                    .foregroundColor(ZumrutColors.gold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let errorMessage = audio.errorMessage {
                    Text(errorMessage)
                        .font(ZumrutFont.body(12))
                        .foregroundColor(ZumrutColors.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 10) {
                    Button {
                        Task { await audio.toggle(duaId: dua.id, arabicText: dua.arabic) }
                    } label: {
                        Group {
                            if audio.isLoading {
                                ProgressView().tint(ZumrutColors.teal)
                            } else {
                                Label(audio.isPlaying ? "Durdur" : "Dinle", systemImage: audio.isPlaying ? "stop.fill" : "play.fill")
                            }
                        }
                        .font(ZumrutFont.body(13, weight: .semibold))
                        .foregroundColor(ZumrutColors.teal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(ZumrutColors.tealTint)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(audio.isLoading)

                    Button {
                        onToggleFavorite()
                    } label: {
                        Label(isFavorite ? "Favorilerde" : "Favorilere Ekle", systemImage: isFavorite ? "star.fill" : "star")
                            .font(ZumrutFont.body(13, weight: .semibold))
                            .foregroundColor(ZumrutColors.gold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ZumrutColors.goldTint)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(dua.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { audio.stop() }
    }
}

private struct AddDuaView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var text = ""
    @State private var category = "Sabah-Akşam"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Başlık", text: $title)
                TextField("Dua metni", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                Picker("Kategori", selection: $category) {
                    ForEach(DuaLibrary.categories, id: \.self) { Text($0) }
                }
            }
            .navigationTitle("Kendi Duanı Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        modelContext.insert(CustomDua(title: title, text: text, category: category))
                        dismiss()
                    }
                    .disabled(title.isEmpty || text.isEmpty)
                }
            }
        }
    }
}
