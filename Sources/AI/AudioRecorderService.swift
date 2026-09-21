import AVFoundation

@MainActor
final class AudioRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    private var recorder: AVAudioRecorder?
    private var recordedFileURL: URL?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .default)
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tilavet-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        recordedFileURL = url
        isRecording = true
    }

    func stopRecording() -> URL? {
        recorder?.stop()
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
        return recordedFileURL
    }
}
