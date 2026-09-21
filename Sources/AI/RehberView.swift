import SwiftUI

struct RehberView: View {
    @EnvironmentObject private var store: StoreManager

    @State private var messages: [ChatMessage] = []
    @State private var input = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    var body: some View {
        if store.isPremium {
            content
        } else {
            PremiumLockedView(
                title: "Rehber Premium'a Özel",
                message: "Sorularınızı yanıtlayan AI rehberi kullanmak için Premium'a geçin."
            )
        }
    }

    private var content: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                bubble(message)
                            }
                            if isSending {
                                HStack {
                                    ProgressView().tint(ZumrutColors.teal)
                                    Text("Düşünüyor...").font(ZumrutFont.mono(11)).foregroundColor(ZumrutColors.muted)
                                }
                            }
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(ZumrutFont.body(12))
                                    .foregroundColor(ZumrutColors.gold)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .id("bottom")
                    }
                    .onChange(of: messages.count) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }

                inputBar
            }
            .navigationTitle("Rehber")
            .background(ZumrutColors.paper)
        }
    }

    private func bubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.text)
                    .font(ZumrutFont.body(13))
                    .foregroundColor(message.role == "user" ? .white : ZumrutColors.ink)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(message.role == "user" ? ZumrutColors.teal : ZumrutColors.line.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            if message.role == "assistant" { Spacer(minLength: 40) }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Bir soru sor...", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(ZumrutColors.line.opacity(0.25))
                .clipShape(Capsule())
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(ZumrutColors.teal)
            }
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func send() {
        let question = input.trimmingCharacters(in: .whitespaces)
        guard !question.isEmpty else { return }
        input = ""
        errorMessage = nil
        let history = messages
        messages.append(ChatMessage(role: "user", text: question))

        Task {
            isSending = true
            defer { isSending = false }
            do {
                let answer = try await RehberService.ask(question, history: history)
                messages.append(ChatMessage(role: "assistant", text: answer))
            } catch {
                errorMessage = "Cevap alınamadı. Tekrar deneyin."
            }
        }
    }
}
