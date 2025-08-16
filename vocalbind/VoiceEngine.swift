import Foundation
import AVFoundation
import AudioToolbox

final class VoiceEngine {
    private let engine = AVAudioEngine()
    private let pitch = AVAudioUnitTimePitch()

    init() {
        engine.attach(pitch)
        // mic -> pitch -> output
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        engine.connect(input, to: pitch, format: format)
        engine.connect(pitch, to: engine.mainMixerNode, format: format)

        // gentle defaults
        pitch.overlap = 8
        pitch.rate = 1.0
        pitch.pitch = 0
    }

    func start() throws {
        if engine.isRunning { return }
        try engine.start()
    }

    func stop() {
        engine.stop()
    }

    /// semitones: -12 ... +12 (±1 octave)
    func set(semitones: Float) {
        // Apple's AU uses cents: 100 cents = 1 semitone
        pitch.pitch = semitones * 100.0
    }
}