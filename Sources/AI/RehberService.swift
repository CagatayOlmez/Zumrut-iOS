import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String // "user" | "assistant"
    let text: String
}

enum RehberError: Error {
    case requestFailed(String)
}

private struct ChatRequestBody: Encodable {
    struct Turn: Encodable { let role: String; let content: String }
    let history: [Turn]
    let question: String
}

private struct ChatResponseBody: Decodable {
    let content: String?
    let error: String?
}

// Proxies through the `chat` Supabase Edge Function (backend/supabase/functions/chat)
// so the OpenAI key and the guiding system prompt live server-side, not in
// the app. See backend/README.md for deployment.
enum RehberService {
    static func ask(_ question: String, history: [ChatMessage]) async throws -> String {
        let body = ChatRequestBody(
            history: history.map { .init(role: $0.role, content: $0.text) },
            question: question
        )

        var request = SupabaseConfig.authorizedRequest(url: SupabaseConfig.functionURL("chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let decoded = try? JSONDecoder().decode(ChatResponseBody.self, from: data)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200, let content = decoded?.content else {
            throw RehberError.requestFailed(decoded?.error ?? "Cevap alınamadı.")
        }
        return content
    }
}
