import Testing
import AVFoundation
@testable import MeowPaw

@Suite(.serialized) @MainActor
struct PlaybackTests {
    @Test func customLabelsPersistAndNeverChangeSounds() {
        let suite = "MeowPawTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = PawLabels(defaults: defaults), sound = PawSound.all[0]
        #expect(store.label(for: sound) == sound.label)
        store.save("  快来呀  ", for: sound)
        #expect(PawLabels(defaults: defaults).label(for: sound) == "快来呀")
        store.save(" \n ", for: sound)
        #expect(store.label(for: sound) == "快来呀")
        store.save(String(repeating: "喵", count: 100), for: sound)
        #expect(store.label(for: sound).count == 60)
        #expect(sound.filename == "cat-1")
        #expect(store.label(for: PawSound.all[1]) == PawSound.all[1].label)
    }

    @Test func bundledCatSoundsDecodeAndActuallyPlay() throws {
        let controller = PlaybackController()
        #expect(controller.soundsReady)
        for sound in PawSound.all {
            let url = try #require(Bundle.main.url(forResource: sound.filename, withExtension: "wav"))
            let audio = try AVAudioPlayer(contentsOf: url)
            #expect(audio.duration > 0.2 && audio.duration < 4)
            controller.tap(sound)
            #expect(controller.activeID == sound.id)
            #expect(controller.isPlaying)
            #expect(controller.currentPlayer?.numberOfLoops == 0)
            #expect(controller.currentPlayer?.volume == 0.55)
            controller.stop()
            #expect(!controller.isPlaying)
        }
    }
    @Test func actualCatRapidSwitchAndSameKeyStop() throws {
        let controller = PlaybackController()
        for i in 0..<120 {
            let old = controller.currentPlayer
            let sound = PawSound.all[i % 12]
            controller.tap(sound)
            #expect(controller.isPlaying)
            #expect(controller.activeID == sound.id)
            if let old { #expect(!old.isPlaying) }
            if i % 8 == 0 {
                let current = controller.currentPlayer
                controller.tap(sound)
                #expect(!controller.isPlaying)
                #expect(current?.isPlaying == false)
            }
        }
        controller.stop()
    }
    @Test func actualCatNaturallyEndsWithoutLoop() async throws {
        let controller = PlaybackController()
        controller.tap(PawSound.all[0])
        #expect(controller.isPlaying)
        let deadline = Date().addingTimeInterval(5)
        while controller.activeID != nil && Date() < deadline { try await Task.sleep(for: .milliseconds(20)) }
        #expect(!controller.isPlaying)
        #expect(controller.activeID == nil)
    }
    // A quiet neutral sine wave is solely a test fixture. Never bundled as a cat sound.
    func fixture(seconds: Double = 5) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
        let rate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(rate * seconds))!
        buffer.frameLength = buffer.frameCapacity
        for i in 0..<Int(buffer.frameLength) { buffer.floatChannelData![0][i] = Float(sin(Double(i) * 2 * .pi * 440 / rate)) * 0.005 }
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        try file.write(from: buffer)
        return url
    }
    @Test func sameButtonStopsRealPlayer() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let controller = PlaybackController(resolve: { _ in url })
        controller.tap(PawSound.all[0]); #expect(controller.isPlaying); #expect(controller.activeID == 0)
        let old = controller.currentPlayer
        controller.tap(PawSound.all[0]); #expect(!controller.isPlaying); #expect(controller.activeID == nil)
        #expect(old?.isPlaying == false)
    }
    @Test func switchAndRapidTapsNeverLeavePlaybackAfterStop() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let controller = PlaybackController(resolve: { _ in url })
        for index in 0..<120 {
            let old = controller.currentPlayer
            controller.tap(PawSound.all[index % 12])
            #expect(controller.activeID == index % 12); #expect(controller.isPlaying)
            if let old { #expect(!old.isPlaying) }
        }
        controller.stop(); #expect(!controller.isPlaying); #expect(controller.activeID == nil)
    }
    @Test func staleCompletionCannotStopNewSound() async throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let controller = PlaybackController(resolve: { _ in url })
        controller.tap(PawSound.all[0]); let old = try #require(controller.currentPlayer)
        controller.tap(PawSound.all[1])
        controller.audioPlayerDidFinishPlaying(old, successfully: true)
        await Task.yield()
        #expect(controller.activeID == 1); #expect(controller.isPlaying)
        controller.stop()
    }
    @Test func naturalEndResetsWithoutLoop() async throws {
        let url = try fixture(seconds: 0.15); defer { try? FileManager.default.removeItem(at: url) }
        let controller = PlaybackController(resolve: { _ in url })
        controller.tap(PawSound.all[0]); #expect(controller.isPlaying)
        let deadline = Date().addingTimeInterval(3)
        while controller.activeID != nil && Date() < deadline { try await Task.sleep(for: .milliseconds(20)) }
        #expect(controller.activeID == nil); #expect(!controller.isPlaying)
    }
    @Test func missingAssetStopsPreviousAndGivesFeedback() throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let controller = PlaybackController(resolve: { $0.id == 0 ? url : nil })
        controller.tap(PawSound.all[0]); #expect(controller.isPlaying)
        controller.tap(PawSound.all[1]); #expect(!controller.isPlaying); #expect(controller.activeID == nil); #expect(controller.message != nil)
    }
    @Test func interruptionStopsWithoutAutoResume() async throws {
        let url = try fixture(); defer { try? FileManager.default.removeItem(at: url) }
        let controller = PlaybackController(resolve: { _ in url })
        controller.tap(PawSound.all[0])
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        let deadline = Date().addingTimeInterval(2)
        while controller.activeID != nil && Date() < deadline { try await Task.sleep(for: .milliseconds(20)) }
        #expect(!controller.isPlaying); #expect(controller.activeID == nil)
    }
}
