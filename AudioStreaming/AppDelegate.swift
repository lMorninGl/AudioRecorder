//
//  AppDelegate.swift
//  AudioStreaming
//
//  Created by Alexey Bondarchuk on 1/4/17.
//  Copyright © 2017 Alexey Bondarchuk. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        AudioController.shared.clearPhrases()
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setMode(AVAudioSessionModeVoiceChat)
        
        return true
    }
}

