import Foundation
import AVFoundation
import AudioToolbox
import Combine

class SoundPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = SoundPlayerService()
    
    @Published var isRinging: Bool = false
    @Published var activeAlarm: AlarmItem? = nil
    @Published var remainingSeconds: Int = 0
    @Published var totalDuration: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var countdownTimer: Timer?
    private var fadeInTimer: Timer?
    private var currentVolume: Float = 0.0
    private var targetVolume: Float = 1.0
    
    override init() {
        super.init()
        configureAudioSession()
    }
    
    // MARK: - Audio Session Setup
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback category ensures audio plays even when the physical mute/silent switch is ON
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Start Alarm Ringing
    func startRinging(for alarm: AlarmItem) {
        // Stop any previous instance
        stopRinging(isUserIntervention: false)
        
        self.activeAlarm = alarm
        self.isRinging = true
        self.totalDuration = alarm.autoSilenceSeconds
        self.remainingSeconds = alarm.autoSilenceSeconds
        
        // Prepare Audio Session
        configureAudioSession()
        
        // Play Audio
        playAlarmAudio(soundId: alarm.soundId, fadeInSeconds: alarm.fadeInSeconds)
        
        // Optional vibration for weekdays (NEVER on Shabbat if disableVibration is true)
        if !alarm.disableVibration {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        // Start countdown timer for automatic shut-off
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.remainingSeconds > 1 {
                self.remainingSeconds -= 1
            } else {
                // Time is up! Turn off automatically without any user touch
                self.remainingSeconds = 0
                self.stopRinging(isUserIntervention: false)
            }
        }
        
        // Keep screen awake while ringing
        #if canImport(UIKit)
        DispatchQueue.main.async {
            import_UIKit_setIdleTimer(false)
        }
        #endif
    }
    
    // MARK: - Stop Alarm
    func stopRinging(isUserIntervention: Bool = false) {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        fadeInTimer?.invalidate()
        fadeInTimer = nil
        
        // Fade out audio gracefully over 0.5s if player exists
        if let player = audioPlayer, player.isPlaying {
            player.setVolume(0.0, fadeDuration: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.audioPlayer?.stop()
                self?.audioPlayer = nil
            }
        } else {
            audioPlayer?.stop()
            audioPlayer = nil
        }
        
        DispatchQueue.main.async {
            self.isRinging = false
            self.activeAlarm = nil
            self.remainingSeconds = 0
        }
    }
    
    // MARK: - Playback & Fade-in Implementation
    private func playAlarmAudio(soundId: String, fadeInSeconds: Int) {
        // Check for bundled audio file or fallback to generated tone
        let sound = AlarmSound.availableSounds.first(where: { $0.id == soundId })
        let fileName = sound?.fileName ?? "gentle_morning.mp3"
        let baseName = (fileName as NSString).deletingPathExtension
        let extName = (fileName as NSString).pathExtension
        
        var audioData: Data? = nil
        if let url = Bundle.main.url(forResource: baseName, withExtension: extName) {
            audioData = try? Data(contentsOf: url)
        } else {
            // Generate procedural melodic beep/chime tone if asset is missing
            audioData = AudioToneGenerator.generateWavData(frequency: 528.0, durationSeconds: 5.0)
        }
        
        guard let data = audioData else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = -1 // Loop continuously until auto-silence timer expires
            
            if fadeInSeconds > 0 {
                currentVolume = 0.05
                audioPlayer?.volume = currentVolume
                audioPlayer?.play()
                
                let stepInterval = 0.5
                let totalSteps = Double(fadeInSeconds) / stepInterval
                let stepVolume = (targetVolume - 0.05) / Float(totalSteps)
                
                fadeInTimer = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { [weak self] timer in
                    guard let self = self, let player = self.audioPlayer else {
                        timer.invalidate()
                        return
                    }
                    if self.currentVolume < self.targetVolume {
                        self.currentVolume = min(self.targetVolume, self.currentVolume + stepVolume)
                        player.volume = self.currentVolume
                    } else {
                        player.volume = self.targetVolume
                        timer.invalidate()
                    }
                }
            } else {
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            }
        } catch {
            print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helper to control Idle Timer
#if canImport(UIKit)
import UIKit
fileprivate func import_UIKit_setIdleTimer(_ disabled: Bool) {
    UIApplication.shared.isIdleTimerDisabled = disabled
}
#endif

// MARK: - Procedural Audio Tone Generator (Ensures sound works immediately without external MP3 files)
enum AudioToneGenerator {
    static func generateWavData(frequency: Double, durationSeconds: Double, sampleRate: Double = 44100.0) -> Data {
        let numSamples = Int(durationSeconds * sampleRate)
        var pcmData = [Int16]()
        pcmData.reserveCapacity(numSamples)
        
        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            // Pleasant dual-frequency chord (Frequency + 5th harmonic)
            let wave1 = sin(2.0 * .pi * frequency * t)
            let wave2 = sin(2.0 * .pi * (frequency * 1.5) * t) * 0.5
            
            // Envelope: gentle pulse every 1 second
            let pulse = 0.5 * (1.0 + sin(2.0 * .pi * 1.0 * t))
            let sample = (wave1 + wave2) * pulse * 0.7
            
            let clamped = max(-1.0, min(1.0, sample))
            pcmData.append(Int16(clamped * 32767.0))
        }
        
        // Build standard 16-bit Mono WAV Header
        var wavHeader = Data()
        let dataSize = numSamples * 2
        let totalChunkSize = 36 + dataSize
        
        wavHeader.append("RIFF".data(using: .ascii)!)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(totalChunkSize).littleEndian) { Array($0) })
        wavHeader.append("WAVE".data(using: .ascii)!)
        wavHeader.append("fmt ".data(using: .ascii)!)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) }) // Subchunk1Size
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // AudioFormat (PCM)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // NumChannels (1)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Array($0) }) // SampleRate
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate * 2).littleEndian) { Array($0) }) // ByteRate
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) })  // BlockAlign
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) }) // BitsPerSample
        wavHeader.append("data".data(using: .ascii)!)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Array($0) })
        
        var fullData = wavHeader
        pcmData.withUnsafeBufferPointer { buffer in
            fullData.append(UnsafeRawBufferPointer(buffer))
        }
        
        return fullData
    }
}
