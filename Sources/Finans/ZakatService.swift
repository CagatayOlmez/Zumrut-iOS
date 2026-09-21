import Foundation

// Live gold/silver spot prices (gold-api.com, no key required) converted to
// TRY via frankfurter.app. Nisab thresholds (85g gold / 595g silver) are the
// widely-accepted standard fıqh values — the lower of the two is used here,
// the common convention for cash/mixed-asset zekât calculators.

struct MetalPrices {
    let goldPricePerGramTRY: Double
    let silverPricePerGramTRY: Double
}

private struct MetalPriceResponse: Decodable {
    let price: Double
}

private struct ExchangeRateResponse: Decodable {
    let rates: [String: Double]
}

private let TROY_OUNCE_IN_GRAMS = 31.1035
let GOLD_NISAB_GRAMS = 85.0
let SILVER_NISAB_GRAMS = 595.0
let ZAKAT_RATE = 0.025

struct ZakatResult {
    let totalAssets: Double
    let nisabTRY: Double
    let isAboveNisab: Bool
    let zakatAmount: Double
}

enum ZakatService {
    // Pure zakat calculation, isolated from the view so it's independently
    // testable — the nisab is the lower of the gold/silver thresholds (the
    // standard convention for cash/mixed-asset zekât), and zakat is only
    // owed once total assets meet or exceed it.
    static func calculate(goldGrams: Double, silverGrams: Double, cashTRY: Double, tradeGoodsTRY: Double, prices: MetalPrices) -> ZakatResult {
        let goldValue = goldGrams * prices.goldPricePerGramTRY
        let silverValue = silverGrams * prices.silverPricePerGramTRY
        let totalAssets = goldValue + silverValue + cashTRY + tradeGoodsTRY
        let nisabTRY = min(GOLD_NISAB_GRAMS * prices.goldPricePerGramTRY, SILVER_NISAB_GRAMS * prices.silverPricePerGramTRY)
        let isAboveNisab = totalAssets >= nisabTRY
        let zakatAmount = isAboveNisab ? totalAssets * ZAKAT_RATE : 0
        return ZakatResult(totalAssets: totalAssets, nisabTRY: nisabTRY, isAboveNisab: isAboveNisab, zakatAmount: zakatAmount)
    }

    static func fetchMetalPricesInTRY() async throws -> MetalPrices {
        async let gold = fetchUSDPricePerOunce(symbol: "XAU")
        async let silver = fetchUSDPricePerOunce(symbol: "XAG")
        async let usdToTry = fetchUSDToTRYRate()

        let (goldOunceUSD, silverOunceUSD, rate) = try await (gold, silver, usdToTry)
        let goldPerGramUSD = goldOunceUSD / TROY_OUNCE_IN_GRAMS
        let silverPerGramUSD = silverOunceUSD / TROY_OUNCE_IN_GRAMS

        return MetalPrices(
            goldPricePerGramTRY: goldPerGramUSD * rate,
            silverPricePerGramTRY: silverPerGramUSD * rate
        )
    }

    private static func fetchUSDPricePerOunce(symbol: String) async throws -> Double {
        let url = URL(string: "https://api.gold-api.com/price/\(symbol)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MetalPriceResponse.self, from: data).price
    }

    private static func fetchUSDToTRYRate() async throws -> Double {
        let url = URL(string: "https://api.frankfurter.app/latest?from=USD&to=TRY")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        guard let rate = decoded.rates["TRY"] else { throw URLError(.cannotParseResponse) }
        return rate
    }
}
