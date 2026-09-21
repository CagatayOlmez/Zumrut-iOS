import SwiftData
import SwiftUI

private let CATEGORIES = ["İftar", "Sohbet", "Cami", "Diğer"]

struct EtkinliklerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CommunityEvent.date) private var events: [CommunityEvent]

    @State private var selectedCategory: String? = nil
    @State private var showingAddSheet = false

    private var upcoming: [CommunityEvent] {
        let now = Date.now
        return events
            .filter { $0.date >= now && (selectedCategory == nil || $0.category == selectedCategory) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryChips

                if upcoming.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Henüz etkinlik yok")
                            .font(ZumrutFont.body(14, weight: .semibold))
                            .foregroundColor(ZumrutColors.ink)
                        Text("İftar daveti, sohbet ya da cami etkinliği ekleyebilirsin.")
                            .font(ZumrutFont.body(12))
                            .foregroundColor(ZumrutColors.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    List {
                        ForEach(upcoming) { event in
                            eventRow(event)
                        }
                        .onDelete { offsets in
                            for index in offsets { modelContext.delete(upcoming[index]) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Etkinlikler")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEventView()
            }
            .background(ZumrutColors.paper)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "Tümü", isSelected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(CATEGORIES, id: \.self) { category in
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

    private func eventRow(_ event: CommunityEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event.title).font(ZumrutFont.body(14, weight: .semibold)).foregroundColor(ZumrutColors.ink)
                Spacer()
                Text(event.category).font(ZumrutFont.mono(10)).foregroundColor(ZumrutColors.gold)
            }
            Text(event.date.formatted(.dateTime.weekday(.wide).day().month(.wide).hour().minute().locale(Locale(identifier: "tr_TR"))))
                .font(ZumrutFont.mono(11))
                .foregroundColor(ZumrutColors.teal)
            Text(event.location)
                .font(ZumrutFont.body(12))
                .foregroundColor(ZumrutColors.muted)
        }
        .padding(.vertical, 4)
    }
}

private struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var location = ""
    @State private var date = Date.now.addingTimeInterval(3600)
    @State private var category = CATEGORIES[0]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Başlık", text: $title)
                TextField("Konum", text: $location)
                DatePicker("Tarih ve saat", selection: $date)
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                Picker("Kategori", selection: $category) {
                    ForEach(CATEGORIES, id: \.self) { Text($0) }
                }
            }
            .navigationTitle("Yeni Etkinlik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        modelContext.insert(CommunityEvent(title: title, location: location, date: date, category: category))
                        dismiss()
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
}
