//
//  ViewController.swift
//  VoiceManager
//
//  Created by APPLE on 2019/9/17.
//  Copyright © 2019 APPLE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mButton_RecordVoice: UIButton!
    @IBOutlet weak var mLabel_RecordTimer: UILabel!
    
    let mVoiceManager = VoiceManager()
    var VoiceRecord_isOpen: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func Click_RecordVoice(_ sender: UIButton) {
        self.mButton_RecordVoice.isEnabled = false
        
        if self.VoiceRecord_isOpen {
            self.VoiceRecord_isOpen = false
            self.mVoiceManager.recordVoice(self, startEnable: self.VoiceRecord_isOpen) { (permissionStatus, seconds, secString, status, url) in
                if permissionStatus {
                    if status {
                        // recording
                        print(secString)
                        self.mButton_RecordVoice.setTitle("Stop", for: .normal)
                        self.mLabel_RecordTimer.text = secString
                    } else {
                        // record end
                        print(url!)
                        print("total_sec:\(secString)")
                        self.mButton_RecordVoice.setTitle("Start", for: .normal)
                        self.mLabel_RecordTimer.text = "点击Start开始录音"
                        
                    }
                } else {
                    self.mButton_RecordVoice.setTitle("Start", for: .normal)
                    self.mLabel_RecordTimer.text = "点击Start开始录音"
                }
                self.mButton_RecordVoice.isEnabled = true
            }
        } else {
            self.VoiceRecord_isOpen = true
            mLabel_RecordTimer.text = "环境准备中"
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.mVoiceManager.recordVoice(self, startEnable: self.VoiceRecord_isOpen) { (permissionStatus, seconds, secString, status, url) in
                    if permissionStatus {
                        if status {
                            // recording
                            print(secString)
                            self.mButton_RecordVoice.setTitle("Stop", for: .normal)
                            self.mLabel_RecordTimer.text = secString
                        } else {
                            // record end
                            print(url!)
                            print("total_sec:\(secString)")
                            self.mButton_RecordVoice.setTitle("Start", for: .normal)
                            self.mLabel_RecordTimer.text = "点击Start开始录音"
                        }
                    } else {
                        self.mButton_RecordVoice.setTitle("Start", for: .normal)
                        self.mLabel_RecordTimer.text = "点击Start开始录音"
                    }
                    self.mButton_RecordVoice.isEnabled = true
                }
            })
        }
        
    }
}

