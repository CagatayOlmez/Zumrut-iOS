import XCTest
@testable import Zumrut

final class ZakatServiceTests: XCTestCase {
    // Simple round-number prices so expected totals are easy to verify by hand.
    // nisab = min(85g * 1000, 595g * 20) = min(85000, 11900) = 11900 TRY.
    private let prices = MetalPrices(goldPricePerGramTRY: 1000, silverPricePerGramTRY: 20)

    func testBelowNisabOwesNoZakat() {
        let result = ZakatService.calculate(goldGrams: 0, silverGrams: 0, cashTRY: 5000, tradeGoodsTRY: 0, prices: prices)
        XCTAssertFalse(result.isAboveNisab)
        XCTAssertEqual(result.zakatAmount, 0)
    }

    func testAboveNisabOwesTwoPointFivePercent() {
        let result = ZakatService.calculate(goldGrams: 0, silverGrams: 0, cashTRY: 20000, tradeGoodsTRY: 0, prices: prices)
        XCTAssertTrue(result.isAboveNisab)
        XCTAssertEqual(result.zakatAmount, 500, accuracy: 0.001)
    }

    func testNisabIsLowerOfGoldAndSilverThresholds() {
        let result = ZakatService.calculate(goldGrams: 0, silverGrams: 0, cashTRY: 0, tradeGoodsTRY: 0, prices: prices)
        XCTAssertEqual(result.nisabTRY, 11900, accuracy: 0.001)
    }

    func testExactlyAtNisabCountsAsAboveNisab() {
        let result = ZakatService.calculate(goldGrams: 0, silverGrams: 0, cashTRY: 11900, tradeGoodsTRY: 0, prices: prices)
        XCTAssertTrue(result.isAboveNisab)
        XCTAssertEqual(result.zakatAmount, 297.5, accuracy: 0.001)
    }

    func testJustBelowNisabOwesNoZakat() {
        let result = ZakatService.calculate(goldGrams: 0, silverGrams: 0, cashTRY: 11899.99, tradeGoodsTRY: 0, prices: prices)
        XCTAssertFalse(result.isAboveNisab)
        XCTAssertEqual(result.zakatAmount, 0)
    }

    func testCombinesGoldSilverCashAndTradeGoods() {
        let result = ZakatService.calculate(goldGrams: 10, silverGrams: 100, cashTRY: 0, tradeGoodsTRY: 0, prices: prices)
        // 10*1000 (gold) + 100*20 (silver) = 12000
        XCTAssertEqual(result.totalAssets, 12000, accuracy: 0.001)
        XCTAssertTrue(result.isAboveNisab)
        XCTAssertEqual(result.zakatAmount, 300, accuracy: 0.001)
    }

    func testZeroInputsAreSafe() {
        let result = ZakatService.calculate(goldGrams: 0, silverGrams: 0, cashTRY: 0, tradeGoodsTRY: 0, prices: prices)
        XCTAssertEqual(result.totalAssets, 0)
        XCTAssertFalse(result.isAboveNisab)
        XCTAssertEqual(result.zakatAmount, 0)
    }
}
