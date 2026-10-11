import AVFoundation
import Observation

struct PawSound: Identifiable {
    let id: Int
    let label: String
    var filename: String { "cat-\(id + 1)" }
    static let all = ["过来", "吃饭啦", "喝水啦", "陪我玩", "抱抱", "摸摸头", "我爱你", "想你了", "真乖", "别闹啦", "起床啦", "晚安"].enumerated().map { PawSound(id: $0.offset, label: $0.element) }
}

@MainActor @Observable
final class PlaybackController: NSObject, AVAudioPlayerDelegate {
    private(set) var activeID: Int?
    private(set) var message: String?
    private(set) var tapCount = 0
    private let resolve: (PawSound) -> URL?
    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var interruption: NSObjectProtocol?
    var isPlaying: Bool { player?.isPlaying ?? false }
    var currentPlayer: AVAudioPlayer? { player }
    var soundsReady: Bool { PawSound.all.allSatisfy { resolve($0) != nil } }
    var volume: Float = 0.55 { didSet { player?.volume = min(max(volume, 0), 0.75) } }

    init(resolve: @escaping (PawSound) -> URL? = { Bundle.main.url(forResource: $0.filename, withExtension: "wav") }) {
        self.resolve = resolve
        super.init()
        interruption = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            guard let value = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  value == AVAudioSession.InterruptionType.began.rawValue else { return }
            Task { @MainActor [weak self] in self?.stop() }
        }
    }

    func tap(_ sound: PawSound) {
        tapCount += 1
        if activeID == sound.id { stop(); return }
        stop()
        guard let url = resolve(sound) else {
            message = "声音文件未找到，请重新安装喵爪"
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)
            let next = try AVAudioPlayer(contentsOf: url)
            next.delegate = self
            next.numberOfLoops = 0
            next.volume = min(max(volume, 0), 0.75)
            next.prepareToPlay()
            guard next.play() else { throw PlaybackError.unavailable }
            player = next
            activeID = sound.id
            message = nil
        } catch {
            stop()
            message = "这声喵没响起来，再试一下吧"
        }
    }

    func stop() {
        player?.delegate = nil
        player?.stop()
        player = nil
        activeID = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    nonisolated func audioPlayerDidFinishPlaying(_ finished: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            guard let self, self.player === finished else { return }
            self.stop()
            if !flag { self.message = "播放已停止，请再试一次" }
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ failed: AVAudioPlayer, error: Error?) {
        Task { @MainActor [weak self] in
            guard let self, self.player === failed else { return }
            self.stop()
            self.message = "这声喵没响起来，再试一下吧"
        }
    }

    deinit {
        player?.stop()
        if let interruption { NotificationCenter.default.removeObserver(interruption) }
    }
    enum PlaybackError: Error { case unavailable }
}
