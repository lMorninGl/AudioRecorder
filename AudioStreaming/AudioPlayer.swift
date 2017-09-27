//
//  AudioPlayer.swift
//  AudioStreaming
//
//  Created by Alexey Bondarchuk on 9/27/17.
//  Copyright © 2017 Alexey Bondarchuk. All rights reserved.
//

import Foundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate
{
    static let shared = AudioPlayer()
    
    var playerFinishedPlayingCallback: (() -> ())!
    
    private(set) var playingPhrase: Phrase?
    
    private var audioPlayer: AVAudioPlayer?
    
    func play(phrase: Phrase)
    {
        self.playingPhrase = phrase
        
        AudioController.shared.pauseListener()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! self.audioPlayer = AVAudioPlayer(contentsOf: phrase.filePath)
        self.audioPlayer?.delegate = self
        self.audioPlayer!.prepareToPlay()
        self.audioPlayer!.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        self.playingPhrase = nil
        self.audioPlayer = nil
        self.playerFinishedPlayingCallback()
        AudioController.shared.startListener()
    }
}
