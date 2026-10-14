import AVFoundation

/// Every sound in the game. They're made with math when the app starts, so there are no audio files.
enum Sound: CaseIterable {
    case swish, zap, shing, buzz, thump, win, lose
}

/// Plays the sounds. Uses the "ambient" setting, so the phone's silent switch mutes it
/// and music from other apps keeps playing.
@MainActor
enum Sounds {
    private static let rate = 44_100.0
    private static let engine = AVAudioEngine()
    private static var nodes: [Sound: AVAudioPlayerNode] = [:]
    private static var buffers: [Sound: AVAudioPCMBuffer] = [:]
    private static var ready = false

    static var isOn: Bool {
        UserDefaults.standard.object(forKey: "sounds") as? Bool ?? true
    }

    static func play(_ sound: Sound) {
        guard isOn else { return }
        setUp()
        guard ready, let node = nodes[sound], let buffer = buffers[sound] else { return }
        if !engine.isRunning { try? engine.start() }
        node.scheduleBuffer(buffer, at: nil, options: .interrupts)
        if !node.isPlaying { node.play() }
    }

    private static func setUp() {
        guard !ready else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1) else { return }
        for sound in Sound.allCases {
            let samples = make(sound)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
                  let channel = buffer.floatChannelData?[0] else { continue }
            buffer.frameLength = AVAudioFrameCount(samples.count)
            for (i, value) in samples.enumerated() { channel[i] = value }
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            nodes[sound] = node
            buffers[sound] = buffer
        }
        engine.mainMixerNode.outputVolume = 0.6
        ready = (try? engine.start()) != nil
    }

    // MARK: - Making the sounds

    private static func make(_ sound: Sound) -> [Float] {
        switch sound {
        case .swish:
            // Air: noise that gets brighter and then fades.
            var low: Float = 0
            return wave(0.28) { t, d in
                let noise = Float.random(in: -1...1)
                let cutoff = Float(0.05 + 0.5 * t / d)
                low += (noise - low) * cutoff
                return low * Float(sin(.pi * t / d)) * 1.4
            }
        case .zap:
            // A laser: a tone that drops fast.
            var phase = 0.0
            return wave(0.3) { t, d in
                phase += 2 * .pi * (1800 - 1600 * t / d) / rate
                return Float(sin(phase) * exp(-t * 7)) * 0.7
            }
        case .shing:
            // A sword: bright ringing metal.
            return wave(0.7) { t, _ in
                let ring = sin(2 * .pi * 2300 * t) + 0.6 * sin(2 * .pi * 3450 * t) + 0.4 * sin(2 * .pi * 5100 * t)
                let hiss = t < 0.04 ? Double.random(in: -1...1) * (1 - t / 0.04) : 0
                return Float((ring * 0.3 + hiss * 0.5) * exp(-t * 5))
            }
        case .buzz:
            // A chainsaw: a rough saw wave that rattles.
            return wave(0.5) { t, d in
                let saw = 2 * (t * 95).truncatingRemainder(dividingBy: 1) - 1
                let rattle = 0.6 + 0.4 * sin(2 * .pi * 28 * t)
                let fade = min(1, (d - t) / 0.1)
                return Float((saw * 0.5 + Double.random(in: -0.2...0.2)) * rattle * fade * 0.6)
            }
        case .thump:
            // The halves landing on the scale.
            return wave(0.3) { t, _ in
                Float(sin(2 * .pi * (90 - 40 * t) * t) * exp(-t * 14) * 0.9)
            }
        case .win:
            return notes([523.25, 659.25, 783.99, 1046.5], length: 0.1, last: 0.35)
        case .lose:
            return notes([392.0, 293.66], length: 0.2, last: 0.35)
        }
    }

    /// `seconds` of sound. The closure gets the time and the length.
    private static func wave(_ seconds: Double, _ sample: (Double, Double) -> Float) -> [Float] {
        (0..<Int(seconds * rate)).map { sample(Double($0) / rate, seconds) }
    }

    /// A little tune, played on a soft triangle wave.
    private static func notes(_ pitches: [Double], length: Double, last: Double) -> [Float] {
        var samples: [Float] = []
        for (index, pitch) in pitches.enumerated() {
            let seconds = index == pitches.count - 1 ? last : length
            samples += wave(seconds) { t, d in
                let cycle = (t * pitch).truncatingRemainder(dividingBy: 1)
                let triangle = 4 * abs(cycle - 0.5) - 1
                let envelope = min(1, t / 0.01) * exp(-t * 3 / d)
                return Float(triangle * envelope * 0.45)
            }
        }
        return samples
    }
}
