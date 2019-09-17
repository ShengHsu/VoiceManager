//
//  VoiceManager.swift
//  VoiceManager
//
//  Created by APPLE on 2019/9/17.
//  Copyright © 2019 APPLE. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VoiceManager: NSObject {
    //Voice
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var viewController: UIViewController?
    var recordCallback : ((Bool, Float, String, Bool, URL?) -> ())?
    var playerCallback : ((Bool) -> ())?
    
    var destinationUrl: URL?
    
    var voiceTimer_Record:Timer!
    var seconds:Float = 0
    
    override init(){
        super.init()
    }
    
    func recordVoice(_ viewController: UIViewController, startEnable: Bool, callback: @escaping ((Bool, Float, String, Bool, URL?) -> ())) {
        recordCallback = callback
        self.viewController = viewController
        configRecordSession(status: startEnable)
    }
    func configRecordSession(status: Bool) {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { permissionAllowed in
                if permissionAllowed {
                    if status {
                        self.startRecord()
                    } else {
                        self.stopRecord()
                    }
                } else {
                    self.recordCallback? (false, 0, "", false, nil)
//                    SetAlert.showAlert(self.viewController!, Message: "您尚未允许存取录音功能")
                }
            }
        } catch {
            print("Session error:", error.localizedDescription)
        }
    }
    
    func getDirectoryPath() -> URL {
        let fileDirectoryURL = FileManager.default.temporaryDirectory
        return fileDirectoryURL
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Float) -> String {
        let hours = Int(seconds / 3600)
        let min = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d", hours) + ":" + String(format: "%02d", min) + ":" + String(format: "%02d", sec)
    }
    
    @objc func updateTimer(){
        print("update time")
        audioRecorder!.updateMeters()
        seconds += 1
        recordCallback? (true ,seconds, secondsToHoursMinutesSeconds(seconds), true, destinationUrl!)
    }
    
    func startRecord () {
        let date = Date()
        let format_date = DateFormatter()
        format_date.dateFormat = "yyyyMMdd_HHmmss"
        let formattedDate = format_date.string(from: date)
        destinationUrl = getDirectoryPath().appendingPathComponent(formattedDate + ".m4a")
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        do {
            print("start record")
            audioRecorder = try AVAudioRecorder(url: destinationUrl!, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            seconds = 0
            DispatchQueue.main.async {
                self.voiceTimer_Record = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            }
        } catch {
            print("Record error:", error.localizedDescription)
        }
    }
    
    func stopRecord () {
        print("stop record")
        audioRecorder.stop()
        audioRecorder = nil
        voiceTimer_Record.invalidate()
        voiceTimer_Record = nil
        recordCallback? (true, seconds, secondsToHoursMinutesSeconds(seconds), false, destinationUrl!)
    }
    
    func playVoice (voiceURL: URL, callback: @escaping ((Bool) -> ())) {
        playerCallback = callback
        if audioPlayer == nil || audioPlayer.url != voiceURL {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer = try AVAudioPlayer(contentsOf: voiceURL)
                audioPlayer.volume = 1.0
                audioPlayer.delegate = self
                audioPlayer.play()
            } catch {
                print("Play error:", error.localizedDescription)
            }
        } else {
            audioPlayer.play()
        }
    }
    
    func stopVoice () {
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
    }
    
    func pauseVoice () {
        if audioPlayer != nil {
            audioPlayer.pause()
        }
    }
    
}

extension VoiceManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerCallback? (true)
    }
}
