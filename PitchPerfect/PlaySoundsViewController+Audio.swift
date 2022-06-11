//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Created by minhdat on 09/06/2022.
//

import UIKit
import AVFoundation

extension PlaySoundsViewController : AVAudioPlayerDelegate {
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTittle = "Recording disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check setting pls"
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Somethings went wrong with your record"
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    enum PlayingState { case playing, notPlaying}
    
    func setupAudio() {
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false){
        audioEngine = AVAudioEngine()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changeRatePitchNode = AVAudioUnitTimePitch()
        
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)

        //connect node
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }

        //schedule to play and start the engine
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime){
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        audioPlayerNode.play()
    }
    
    @objc func stopAudio(){
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        
    }
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count - 1{
            audioEngine.connect(nodes[x], to:nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    func configureUI(_ playState: PlayingState) {
        switch(playState){
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
            print("is playing")
            
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
            print("is not playing")

        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool){
        slow.isEnabled = enabled
        fast.isEnabled = enabled
        highPitch.isEnabled = enabled
        lowPitch.isEnabled = enabled
        echo.isEnabled = enabled
        reverb.isEnabled = enabled
        stopButton.isEnabled = enabled
    }
    
    func showAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
