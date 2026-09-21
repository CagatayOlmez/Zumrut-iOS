import StoreKit

// Real StoreKit 2 client code. It will show "ürün bulunamadı" until either:
// (a) these product IDs exist as real subscriptions in App Store Connect, or
// (b) a StoreKit Configuration file is attached to the Xcode scheme
//     (File > New > StoreKit Configuration, then Scheme > Edit Scheme > Run >
//     Options > StoreKit Configuration) for local testing without a real
//     App Store Connect setup. Neither step can be done from this session.
enum ProductID {
    static let monthly = "com.cagatayolmez.Zumrut.premium.monthly"
    static let yearly = "com.cagatayolmez.Zumrut.premium.yearly"
    static let all: [String] = [monthly, yearly]
}

@MainActor
final class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPremium = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: ProductID.all)
            if products.isEmpty {
                errorMessage = "Ürünler bulunamadı — App Store Connect'te abonelik ürünleri henüz tanımlanmamış."
            }
        } catch {
            errorMessage = "Ürünler yüklenemedi. Tekrar deneyin."
        }
        await refreshEntitlements()
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Satın alma tamamlanamadı."
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = "Geri yükleme tamamlanamadı."
        }
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, ProductID.all.contains(transaction.productID) {
                active = true
            }
        }
        isPremium = active
    }
}
