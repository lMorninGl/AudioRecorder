//
//  AudioRecording.swift
//  AudioStreaming
//
//  Created by Alexey Bondarchuk on 9/27/17.
//  Copyright © 2017 Alexey Bondarchuk. All rights reserved.
//

import UIKit

class AudioRecording
{
    let name: String
    let fileURL: URL
    
    private var recorder: AVAudioRecorder!
    
    required init(fileURL: URL, name: String)
    {
        self.fileURL = fileURL
        self.name = name
    }
    
    func start()
    {
        let settings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            ]
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        
        self.recorder = try! AVAudioRecorder(url: self.fileURL, settings: settings)
        self.recorder.isMeteringEnabled = true
        self.recorder.record()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAudioInterruption(notification:)), name: .AVAudioSessionInterruption, object: nil)
    }
    
    func stop()
    {
        self.recorder.stop()
        
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: nil)
    }
    
    private var interruptionStartTime: TimeInterval = 0.0
    private var interruptionEndTime: TimeInterval = 0.0
    @objc private func onAudioInterruption(notification: Notification)
    {
        let interruptionType = notification.userInfo![AVAudioSessionInterruptionTypeKey]! as! NSNumber
        if interruptionType.intValue == 1 // Interruption started
        {
            self.recorder.pause()
            self.interruptionStartTime = Date().timeIntervalSince1970
        }
        else
        {
            self.interruptionEndTime = Date().timeIntervalSince1970
            self.fillWithZeros()
            self.recorder.record()
        }
    }
    
    private func fillWithZeros()
    {
        let secondsElapsed = self.interruptionEndTime - self.interruptionStartTime
        let millisecondsElapsed = Int(secondsElapsed * 1000.0)
        
        let packetsPerMillisecond = 16
        let bytesPerPacket = 2
        
        let bytesToWrite = millisecondsElapsed * packetsPerMillisecond * bytesPerPacket
        
        let bytes = [UInt8](repeating: 0, count: bytesToWrite)
        let data = NSData(bytes: bytes, length: bytesToWrite) as Data
        
        let fileHandle = try! FileHandle(forWritingTo: self.fileURL)
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
        fileHandle.closeFile()
    }
}
