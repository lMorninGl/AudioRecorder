//
//  ViewController.swift
//  AudioStreaming
//
//  Created by Alexey Bondarchuk on 1/4/17.
//  Copyright © 2017 Alexey Bondarchuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    enum State
    {
        case stopped
        case recording
    }
    
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var tableView: UITableView!
    
    private var state = State.stopped
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupPlot()
        
        AudioController.shared.startListener()
        AudioController.shared.phraseAddedCallback = { [unowned self] in
            let indexPath = IndexPath(row: AudioController.shared.phrases.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        AudioPlayer.shared.playerFinishedPlayingCallback = { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    private func setupPlot()
    {
        self.audioPlot.plotType = .rolling
        self.audioPlot.gain = 10.0
        self.audioPlot.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        AudioController.shared.chartDataCallback = { [unowned self] buffer, bufferSize in
            self.audioPlot.updateBuffer(buffer, withBufferSize: bufferSize)
        }
    }
    
    @IBAction func onRecordingButton()
    {
        if self.state == .stopped
        {
            self.audioPlot.clear()
            AudioController.shared.startMainRecording()
            self.recordingButton.setTitle("Stop Recording", for: .normal)
            self.state = .recording
        }
        else
        {
            AudioController.shared.stopMainRecording()
            self.recordingButton.setTitle("Start", for: .normal)
            self.state = .stopped
        }
    }
    
    // MARK: Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AudioController.shared.phrases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhraseCell
        let phrase = AudioController.shared.phrases[indexPath.row]
        cell.label.text = phrase.name
        
        if let currentPlayingPhrase = AudioPlayer.shared.playingPhrase
        {
            cell.speakerIcon.isHidden = currentPlayingPhrase.name != phrase.name
        }
        else
        {
            cell.speakerIcon.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let phrase = AudioController.shared.phrases[indexPath.row]
        AudioPlayer.shared.play(phrase: phrase)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
