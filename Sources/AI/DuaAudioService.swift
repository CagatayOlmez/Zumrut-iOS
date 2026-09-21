import AVFoundation
import Foundation

enum DuaAudioError: Error {
    case requestFailed
}

private struct TTSResponse: Decodable {
    let audioUrl: String
}

// Recitation playback for a dua — calls the `tts` edge function, which
// generates (once, then caches server-side) an mp3 via OpenAI TTS and
// returns its URL. See backend/supabase/functions/tts.
@MainActor
final class DuaAudioService: ObservableObject {
    @Published var isLoading = false
    @Published var isPlaying = false
    @Published var errorMessage: String?

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    func toggle(duaId: String, arabicText: String) async {
        if isPlaying {
            stop()
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let url = try await fetchAudioURL(duaId: duaId, text: arabicText)
            play(url: url)
        } catch {
            errorMessage = "Ses alınamadı. Tekrar deneyin."
        }
    }

    private func fetchAudioURL(duaId: String, text: String) async throws -> URL {
        var request = SupabaseConfig.authorizedRequest(url: SupabaseConfig.functionURL("tts"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["duaId": duaId, "text": text])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw DuaAudioError.requestFailed
        }
        let decoded = try JSONDecoder().decode(TTSResponse.self, from: data)
        guard let url = URL(string: decoded.audioUrl) else { throw DuaAudioError.requestFailed }
        return url
    }

    private func play(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
        }
        player.play()
        isPlaying = true
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }
}
