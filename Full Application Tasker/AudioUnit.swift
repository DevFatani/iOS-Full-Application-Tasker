//
//  AudioUnit.swift
//  Full Application Tasker
//
//  Created by Muhammad Fatani on 26/06/2018.
//  Copyright © 2018 Muhammad Fatani. All rights reserved.
//
import AVFoundation
import Foundation
class AudioPlayerUnit :NSObject, AVAudioPlayerDelegate {
    private let TAG = "AudioPlayerUnit"
    
    private var timer: Timer!
    private var player : AVAudioPlayer!
    private var delegate: AudioPlayerUnitDelegate!
    
    init(audioURL: URL, _ delegate: AudioPlayerUnitDelegate) {
        super.init()
        self.delegate = delegate
        self.prepareRecordingSession(category: AVAudioSessionCategoryPlayback)
        
        do {
            self.player = try AVAudioPlayer(contentsOf: audioURL)
        }catch {
            self.delegate.onPlayerFail()
            Logger.error(tag: TAG, message: error)
        }
        
        self.player.delegate = self
        self.player.prepareToPlay()
        
    }
    
    func playAudio(){
        self.player.play()
        self.delegate.onPlayingBegin()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.eachSecondHandler), userInfo: nil, repeats: true);
    }
    
    func pauseAudio(){
        if self.isAudioPlaying{
            self.player.pause()
            self.delegate.onPlayingPaused()
        }
    }
    
    func stopAudio(){
        if self.isAudioPlaying {
            self.player.stop()
            self.timer.invalidate()
        }
    }
    
    public var isAudioPlaying: Bool {
        if self.player == nil{
            return false
        }
        return self.player.isPlaying
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.timer.invalidate()
        if flag {
            self.delegate?.onPlayingEnd()
        }
    }
    
    private func prepareRecordingSession(category: String){
        let recordSession = AVAudioSession.sharedInstance()
        do{
            try recordSession.setCategory(category)
            try recordSession.setActive(true)
        }catch let error {
            Logger.error(tag: TAG, message: error)
        }
        
    }

    @objc func eachSecondHandler(){
        if let player = self.player {
            if player.isPlaying {
                let min = Int(player.currentTime / 60)
                let sec = Int(player.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                self.delegate.onPlayingCurrentTime(time: s)
                player.updateMeters()
            }
        }
    }
}
class AudioRecordingUnit: NSObject, AVAudioRecorderDelegate {
    private let TAG = "AudioRecordingUnit"
    
    private var audioURL: URL!
    private var settings: [String: Any]!
    private var recorder: AVAudioRecorder!
    public var delegate : AudioRecordingUnitDelegate!
    
    /// Determain the time of play or recording
    private var timer : Timer!
    private var durationInSeconds : Int = 60
    private var currentRecordingSecond : Int = 0
    
    required init(_ delegate : AudioRecordingUnitDelegate){
        super.init()
        self.delegate = delegate
        self.settings =  [
            AVFormatIDKey: Int(kAudioFormatULaw),
            AVSampleRateKey: 15500.0,
            AVLinearPCMBitDepthKey : 8,
            AVLinearPCMIsBigEndianKey : false,
            AVLinearPCMIsFloatKey : false
            ] as [String : Any]
        self.prepareRecordingSession(category: AVAudioSessionCategoryRecord)
        self.audioURL = FileUnit.getRealPath(fileName: "\(UUID.init().uuidString).wav")
        
        do {
            self.recorder = try AVAudioRecorder (url: self.audioURL, settings: self.settings)
        } catch let error {
            Logger.error(tag: TAG, message: error)
            self.finishRecording(success: false)
        }
        self.recorder.delegate = self
    }
    
    //==========================[AVAudioSession]====================
    private func prepareRecordingSession(category: String){
        let recordSession = AVAudioSession.sharedInstance()
        do{
            try recordSession.setCategory(category, with: .defaultToSpeaker)
            try recordSession.setActive(true)
        }catch{
            self.delegate?.onRecordingSessionFail()
        }
        
        recordSession.requestRecordPermission({ (isPermissionAccepted) in
            if isPermissionAccepted {
                self.delegate.onPermissionAccepted()
            }else{
                self.delegate.onPermissionDenied()
            }
        })
    }

    
    public var isRecording: Bool {
        return self.recorder != nil && self.recorder.isRecording
    }
    
    func startRecording() {
        self.delegate.onRecordingBegin(isPrepare: self.recorder.prepareToRecord())
        self.recorder.record()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.eachSecondHandler), userInfo: nil, repeats: true);
    }
    
     private func finishRecording(success: Bool) {
        self.recorder.stop()
        self.timer.invalidate()
        if success {
            self.delegate.onRecordingEnd()
        } else {
            self.delegate.onRecordingFail()
        }
    }
    
    func finishRecording() -> URL{
        self.recorder.stop()
        self.timer.invalidate()
        self.delegate.onRecordingEnd()
        return self.audioURL
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(success: flag)
    }
    
    @objc func eachSecondHandler(){
        if let recorder = self.recorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                self.delegate.onRecordingCurrentTime(time: s)
                recorder.updateMeters()
            }
        }
    }
}

protocol AudioPlayerUnitDelegate {
    /// Call this function when the player is begin
    func onPlayingBegin()
    
    /// Call this function when the player is paused
    func onPlayingPaused()
    
    
    /// Call this function when the player is end
    func onPlayingEnd()
    
    /// Call this function when the player is fail to play
    func onPlayerFail()
    
    func onPlayingCurrentTime(time: String)
    
}
protocol AudioRecordingUnitDelegate {
    
    //==========================[Recording]====================
    
    /// Call this function when the recording is begin
    func onRecordingBegin(isPrepare:Bool)
    
    
    /// Call this function when the recording is end
    func onRecordingEnd()
    
    
    /// Call this function to pass the duration
    ///
    /// - Parameter duration: by seconds
//    func onRecordingReachedAt(duration: Int)
    func onRecordingCurrentTime(time: String)
    
    /// Call this function when the recording is fail
    func onRecordingFail()
    
    /// Call this function when the recording is fail
    func onRecordingSessionFail()
    
    
    //==========================[Permission]====================
    
    /// Call this function when the user accept the permission
    func onPermissionAccepted()
    
    
    /// Call this function when the user did not accept the permission
    func onPermissionDenied()
}
