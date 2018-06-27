//
//  RecordingAudio.swift
//  Full Application Tasker
//
//  Created by Muhammad Fatani on 25/06/2018.
//  Copyright © 2018 Muhammad Fatani. All rights reserved.
//
import UIKit
import AVFoundation
import Foundation
class RecordingAudio : UIViewController, AudioPlayerUnitDelegate, AudioRecordingUnitDelegate {
    
    private let TAG = "RecordingAudio"
    private var playerUnit: AudioPlayerUnit!
    private var recordUnit: AudioRecordingUnit!
//    private var audioFile: URL?
    private var isRecording = false
    
    @IBAction func onRecord(_ sender: UIButton) {
        if !self.isRecording{
            self.recordUnit = AudioRecordingUnit(self)
            self.recordUnit.startRecording()
            self.isRecording = true;
        }else {
            
            let audioFile = self.recordUnit.finishRecording()
            self.playerUnit = AudioPlayerUnit(audioURL: audioFile, self)
            self.isRecording = false
        }
    }
    @IBAction func onPlay(_ sender: UIButton) {
        if  !self.playerUnit.isAudioPlaying {
            self.playerUnit.playAudio()
        }else {
            self.playerUnit.pauseAudio()
        }
    }
    
    func onRecordingEnd() {
        
    }
    
    func onRecordingFail() {
        
    }
    
    func onRecordingSessionFail() {
        
    }
    
    func onRecordingBegin(isPrepare: Bool) {
        Logger.normal(tag: TAG, message: isPrepare)
    }
    
    
    func onPlayingBegin() {
        
    }
    
    func onPlayerFail() {
        
    }
    
    func onPlayingEnd() {
        
    }
    
    func onPlayingPaused() {
        
    }
    
    func onPlayingCurrentTime(time: String) {
        Logger.normal(tag: TAG, message: "\(#function) \(time)")
    }
    
    func onRecordingCurrentTime(time: String) {
        Logger.normal(tag: TAG, message: "\(#function) \(time)")
    }
    
    
    func onPermissionDenied() {
        Logger.error(tag: TAG, message: "onPermissionDenied")
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func onPermissionAccepted() {
        Logger.normal(tag: TAG, message: "onPermissionAccepted")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.playerUnit != nil {
            if self.playerUnit.isAudioPlaying {
                self.playerUnit.stopAudio()
            }
        }
        
        if self.recordUnit != nil {
            if self.recordUnit.isRecording {
                let _ = self.recordUnit.finishRecording()
            }
        }
    }
    


}



