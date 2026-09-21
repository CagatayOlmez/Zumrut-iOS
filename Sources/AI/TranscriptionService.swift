import Foundation

enum TranscriptionError: Error {
    case requestFailed
}

private struct TranscriptionResponseBody: Decodable {
    let text: String?
    let error: String?
}

// Proxies through the `transcribe` Supabase Edge Function
// (backend/supabase/functions/transcribe) so the OpenAI key lives
// server-side, not in the app. See backend/README.md for deployment.
enum TranscriptionService {
    static func transcribe(audioFileURL: URL) async throws -> String {
        let boundary = UUID().uuidString
        var request = SupabaseConfig.authorizedRequest(url: SupabaseConfig.functionURL("transcribe"))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let audioData = try Data(contentsOf: audioFileURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        let decoded = try? JSONDecoder().decode(TranscriptionResponseBody.self, from: data)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200, let text = decoded?.text else {
            throw TranscriptionError.requestFailed
        }
        return text
    }
}
