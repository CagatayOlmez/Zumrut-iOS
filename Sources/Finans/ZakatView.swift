import SwiftData
import SwiftUI

struct ZakatView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var goldGrams = ""
    @State private var silverGrams = ""
    @State private var cashTRY = ""
    @State private var tradeGoodsTRY = ""

    @State private var prices: MetalPrices?
    @State private var errorMessage: String?
    @State private var didAddToDonations = false

    private var result: ZakatResult? {
        guard let prices else { return nil }
        return ZakatService.calculate(
            goldGrams: Double(goldGrams) ?? 0,
            silverGrams: Double(silverGrams) ?? 0,
            cashTRY: Double(cashTRY) ?? 0,
            tradeGoodsTRY: Double(tradeGoodsTRY) ?? 0,
            prices: prices
        )
    }

    private var isAboveNisab: Bool { result?.isAboveNisab ?? false }
    private var zakatAmount: Double { result?.zakatAmount ?? 0 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Zekât Hesaplayıcı")
                    .font(ZumrutFont.display(20))
                    .foregroundColor(ZumrutColors.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                if let errorMessage {
                    Text(errorMessage)
                        .font(ZumrutFont.body(13))
                        .foregroundColor(ZumrutColors.muted)
                        .padding(.horizontal, 20)
                } else if prices == nil {
                    HStack {
                        ProgressView().tint(ZumrutColors.teal)
                        Text("Güncel altın/gümüş fiyatı alınıyor...")
                            .font(ZumrutFont.body(12))
                            .foregroundColor(ZumrutColors.muted)
                    }
                    .padding(.horizontal, 20)
                } else {
                    assetFields
                    nisabTag
                    resultCard
                    addButton
                }
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ZumrutColors.paper)
        .task { await loadPrices() }
    }

    private var assetFields: some View {
        VStack(spacing: 0) {
            field(label: "Altın (gram)", text: $goldGrams)
            field(label: "Gümüş (gram)", text: $silverGrams)
            field(label: "Nakit / Banka (₺)", text: $cashTRY)
            field(label: "Ticari Mal (₺)", text: $tradeGoodsTRY)
        }
        .padding(.horizontal, 20)
    }

    private func field(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label).font(ZumrutFont.body(14)).foregroundColor(ZumrutColors.ink)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(ZumrutFont.mono(14))
                .foregroundColor(ZumrutColors.muted)
                .frame(width: 100)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(ZumrutColors.line).frame(height: 1) }
    }

    private var nisabTag: some View {
        Text(isAboveNisab ? "Nisap aşıldı" : "Nisabın altında")
            .font(ZumrutFont.mono(11))
            .foregroundColor(isAboveNisab ? ZumrutColors.teal : ZumrutColors.muted)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isAboveNisab ? ZumrutColors.tealTint : ZumrutColors.line.opacity(0.3))
            .clipShape(Capsule())
            .padding(.horizontal, 20)
    }

    private var resultCard: some View {
        VStack(spacing: 4) {
            Text("ZEKÂTIN").font(ZumrutFont.mono(11)).foregroundColor(ZumrutColors.muted)
            Text(formatTRY(zakatAmount))
                .font(ZumrutFont.display(28))
                .foregroundColor(ZumrutColors.gold)
            Text("Toplam varlık × %2,5").font(ZumrutFont.mono(11)).foregroundColor(ZumrutColors.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(ZumrutColors.goldTint)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(ZumrutColors.gold))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }

    private var addButton: some View {
        Button {
            modelContext.insert(Donation(title: "Zekât", amountTRY: zakatAmount, category: "Zekât"))
            didAddToDonations = true
        } label: {
            Text(didAddToDonations ? "Bağış Takibine Eklendi ✓" : "Bağış Takibine Ekle")
                .font(ZumrutFont.body(14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(zakatAmount > 0 ? ZumrutColors.teal : ZumrutColors.line)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(zakatAmount <= 0 || didAddToDonations)
        .padding(.horizontal, 20)
    }

    private func formatTRY(_ value: Double) -> String {
        String(format: "%.0f ₺", value)
    }

    private func loadPrices() async {
        do {
            prices = try await ZakatService.fetchMetalPricesInTRY()
        } catch {
            errorMessage = "Güncel fiyatlar alınamadı. Tekrar deneyin."
        }
    }
}
