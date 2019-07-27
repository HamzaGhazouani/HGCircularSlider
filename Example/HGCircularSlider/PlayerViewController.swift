//
//  PlayerViewController.swift
//  HGCircularSlider
//
//  Created by Hamza Ghazouani on 08/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

import HGCircularSlider

/*
 KVO context used to differentiate KVO callbacks for this class versus other
 classes in its class hierarchy.
 */
private var playerViewControllerKVOContext = 0


class PlayerViewController: UIViewController {

    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playerSegmentedControl: UISegmentedControl!
    
    let audioPlayer = AVPlayer()
    
    // date formatter user for timer label
    let dateComponentsFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.zeroFormattingBehavior = .pad
            formatter.allowedUnits = [.minute, .second]
            
            return formatter
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudioPlayer()
        
        circularSlider.addTarget(self, action: #selector(pause), for: .editingDidBegin)
        circularSlider.addTarget(self, action: #selector(play), for: .editingDidEnd)
        circularSlider.addTarget(self, action: #selector(updateTimer), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(playerItemDidReachEnd(_:)),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: audioPlayer.currentItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func togglePlayer(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            let currentTime = Float64(circularSlider.endPointValue)
            let newTime = CMTimeMakeWithSeconds(currentTime, preferredTimescale: 600)
            audioPlayer.seek(to: newTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            audioPlayer.play()
        default:
            audioPlayer.pause()
        }
    }
    
    @objc func play() {
        self.playerSegmentedControl.selectedSegmentIndex = 0
        togglePlayer(playerSegmentedControl)
    }
    
    @objc func pause() {
        self.playerSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        togglePlayer(playerSegmentedControl)
    }

    
    /**
     setup and play the sound of the local mp3 file
     */
    func setupAudioPlayer() {
        // TODO: load the audio file asynchronously and observe player status
        guard let audioFileURL = Bundle.main.url(forResource: "StrangeZero", withExtension: "mp3") else { return }
        let asset = AVURLAsset(url: audioFileURL, options: nil)
        let playerItem = AVPlayerItem(asset: asset)
        audioPlayer.replaceCurrentItem(with: playerItem)
        audioPlayer.actionAtItemEnd = .pause
        
        let durationInSeconds = CMTimeGetSeconds(asset.duration)
        circularSlider.maximumValue = CGFloat(durationInSeconds)
        let interval = CMTimeMake(value: 1, timescale: 4)
        audioPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
            [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.updatePlayerUI(withCurrentTime: CGFloat(seconds))
        }

        self.audioPlayer.play()
    }
    
    
    // update the slider position and the timer text
    func updatePlayerUI(withCurrentTime currentTime: CGFloat) {
        circularSlider.endPointValue = currentTime
        var components = DateComponents()
        components.second = Int(currentTime)
        timerLabel.text = dateComponentsFormatter.string(from: components)
    }
    
    @objc func updateTimer() {
        var components = DateComponents()
        components.second = Int(circularSlider.endPointValue)
        timerLabel.text = dateComponentsFormatter.string(from: components)
    }
    
    // MARK: - Notification 
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero,completionHandler:nil)
            playerSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
