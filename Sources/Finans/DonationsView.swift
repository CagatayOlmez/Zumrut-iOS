import SwiftData
import SwiftUI

struct DonationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Donation.date, order: .reverse) private var donations: [Donation]

    @State private var showingAddSheet = false
    private let calendar = Calendar.current

    private var thisYearTotal: Double {
        let year = calendar.component(.year, from: .now)
        return donations
            .filter { calendar.component(.year, from: $0.date) == year }
            .reduce(0) { $0 + $1.amountTRY }
    }

    // Last 6 months' totals, oldest first, for the mini bar chart.
    private var monthlyTotals: [Double] {
        (0..<6).reversed().map { offset in
            guard let month = calendar.date(byAdding: .month, value: -offset, to: .now) else { return 0 }
            let comps = calendar.dateComponents([.year, .month], from: month)
            return donations
                .filter { calendar.dateComponents([.year, .month], from: $0.date) == comps }
                .reduce(0) { $0 + $1.amountTRY }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                summaryCard
                if donations.isEmpty {
                    Spacer()
                    Text("Henüz bağış kaydı yok")
                        .font(ZumrutFont.body(13))
                        .foregroundColor(ZumrutColors.muted)
                    Spacer()
                } else {
                    List {
                        ForEach(donations) { donation in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(donation.title).font(ZumrutFont.body(14, weight: .semibold))
                                    Text(donation.date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR"))))
                                        .font(ZumrutFont.mono(11))
                                        .foregroundColor(ZumrutColors.muted)
                                }
                                Spacer()
                                Text(String(format: "%.0f ₺", donation.amountTRY))
                                    .font(ZumrutFont.mono(13))
                                    .foregroundColor(ZumrutColors.teal)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets { modelContext.delete(donations[index]) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Bağışlarım")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddSheet = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddSheet) { AddDonationView() }
            .background(ZumrutColors.paper)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BU YIL TOPLAM").font(ZumrutFont.mono(11)).foregroundColor(.white.opacity(0.8))
            Text(String(format: "%.0f ₺", thisYearTotal))
                .font(ZumrutFont.display(24))
                .foregroundColor(.white)

            let maxValue = max(monthlyTotals.max() ?? 1, 1)
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(monthlyTotals.enumerated()), id: \.offset) { _, value in
                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .frame(height: max(4, 28 * value / maxValue))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 28)
        }
        .padding(16)
        .background(ZumrutColors.teal)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

private let DONATION_CATEGORIES = ["Zekât", "Sadaka", "Fitre"]

private struct AddDonationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var category = DONATION_CATEGORIES[0]
    @State private var date = Date.now

    var body: some View {
        NavigationStack {
            Form {
                TextField("Kurum / Açıklama", text: $title)
                TextField("Tutar (₺)", text: $amount).keyboardType(.decimalPad)
                Picker("Kategori", selection: $category) {
                    ForEach(DONATION_CATEGORIES, id: \.self) { Text($0) }
                }
                DatePicker("Tarih", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "tr_TR"))
            }
            .navigationTitle("Yeni Bağış")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("İptal") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        let value = Double(amount) ?? 0
                        modelContext.insert(Donation(title: title, amountTRY: value, category: category, date: date))
                        dismiss()
                    }
                    .disabled(title.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
}
