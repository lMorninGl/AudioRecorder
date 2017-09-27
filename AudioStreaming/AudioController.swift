//
//  AudioController.swift
//  AudioStreaming
//
//  Created by Alexey Bondarchuk on 9/27/17.
//  Copyright © 2017 Alexey Bondarchuk. All rights reserved.
//

import UIKit

struct Phrase
{
    let name: String
    let filePath: URL
}

class AudioController: NSObject, EZMicrophoneDelegate
{
    static let shared = AudioController()
    
    var chartDataCallback: ((UnsafeMutablePointer<Float>?, UInt32) -> ())!
    var phraseAddedCallback: (() -> ())!
    
    private(set) var phrases: [Phrase] = []
    
    private var documentsDirectory: String
    {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    private var phrasesDirectory: String
    {
        return self.documentsDirectory + "/phrases/"
    }
    
    private let recognitionStartThreshold: Float = 3
    private let recognitionContinueThreshold: Float = 2
    private let allowedInterval = 10
    
    private lazy var microphone = EZMicrophone(delegate: self, startsImmediately: false)!
    private var mainRecording: AudioRecording!
    private var currentPhraseRecording: AudioRecording!
    
    func clearPhrases()
    {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.phrasesDirectory, isDirectory: nil)
        {
            try! fileManager.createDirectory(atPath: self.phrasesDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        let directoryEnumerator = fileManager.enumerator(atPath: self.phrasesDirectory)!
        while let file = directoryEnumerator.nextObject()
        {
            try! fileManager.removeItem(atPath: file as! String)
        }
        
        self.phrases.removeAll()
    }
    
    func startListener()
    {
        self.microphone.startFetchingAudio()
    }
    
    func pauseListener()
    {
        self.microphone.stopFetchingAudio()
    }
    
    func startMainRecording()
    {
        let path = self.documentsDirectory + "/\(Date().timeIntervalSince1970).wav"
        let url = URL(fileURLWithPath: path)
        
        self.mainRecording = AudioRecording(fileURL: url, name: "Main")
        self.mainRecording.start()
    }
    
    func stopMainRecording()
    {
        self.mainRecording.stop()
    }
    
    private var missedThreshold = 0
    // MARK: Microphone delegate
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32)
    {
        var averageValue: Float = 0.0
        var count = 0
        for subArray in UnsafeBufferPointer(start: buffer, count: Int(numberOfChannels))
        {
            self.chartDataCallback(subArray, bufferSize)
            for v in UnsafeBufferPointer(start: subArray, count: Int(bufferSize))
            {
                averageValue += v
                count += 1
            }
        }
        
        if abs(averageValue) >= self.recognitionStartThreshold && self.currentPhraseRecording == nil // Phrase is starting
        {
            print("Phrase started")
            let phraseNumber = self.phrases.count + 1
            let name = "Phrase #\(phraseNumber)"
            let path = self.documentsDirectory + "/phrase_\(phraseNumber).wav"
            let url = URL(fileURLWithPath: path)
            
            self.currentPhraseRecording = AudioRecording(fileURL: url, name: name)
            self.currentPhraseRecording.start()
            
            self.missedThreshold = 0
        }
        else if abs(averageValue) < self.recognitionContinueThreshold && self.currentPhraseRecording != nil // Phrase is recording, but recognition threshold wasn't reached
        {
            self.missedThreshold += 1
            if self.missedThreshold >= self.allowedInterval
            {
                self.phrases.append(Phrase(name: self.currentPhraseRecording.name, filePath: self.currentPhraseRecording.fileURL))
                
                self.currentPhraseRecording.stop()
                self.currentPhraseRecording = nil
                
                DispatchQueue.main.async {
                    self.phraseAddedCallback()
                }
                print("Phrase ended")
            }
        }
        else if abs(averageValue) >= self.recognitionContinueThreshold && self.currentPhraseRecording != nil // Reset missed counter
        {
            self.missedThreshold = 0
        }
    }
}
