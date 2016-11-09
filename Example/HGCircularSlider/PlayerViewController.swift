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
    let dateComponentsFormatter: NSDateComponentsFormatter = {
            let formatter = NSDateComponentsFormatter()
            formatter.zeroFormattingBehavior = .Pad
            formatter.allowedUnits = [.Minute, .Second]
            
            return formatter
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudioPlayer()
        
        circularSlider.addTarget(self, action: #selector(pause), forControlEvents: .EditingDidBegin)
        circularSlider.addTarget(self, action: #selector(play), forControlEvents: .EditingDidEnd)
        circularSlider.addTarget(self, action: #selector(updateTimer), forControlEvents: .ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(playerItemDidReachEnd(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: audioPlayer.currentItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func togglePlayer(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            let currentTime = Float64(circularSlider.endPointValue)
            let newTime = CMTimeMakeWithSeconds(currentTime, 600)
            audioPlayer.seekToTime(newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            audioPlayer.play()
        default:
            audioPlayer.pause()
        }
    }
    
    func play() {
        self.playerSegmentedControl.selectedSegmentIndex = 0
        togglePlayer(playerSegmentedControl)
    }
    
    func pause() {
        self.playerSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        togglePlayer(playerSegmentedControl)
    }

    
    /**
     setup and play the sound of the local mp3 file
     */
    func setupAudioPlayer() {
        // TODO: load the audio file asynchronously and observe player status
        guard let audioFileURL = NSBundle.mainBundle().URLForResource("StrangeZero", withExtension: "mp3") else { return }
        let asset = AVURLAsset(URL: audioFileURL, options: nil)
        let playerItem = AVPlayerItem(asset: asset)
        audioPlayer.replaceCurrentItemWithPlayerItem(playerItem)
        audioPlayer.actionAtItemEnd = .Pause
        
        let durationInSeconds = CMTimeGetSeconds(asset.duration)
        circularSlider.maximumValue = CGFloat(durationInSeconds)
        let interval = CMTimeMake(1, 4)
        audioPlayer.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) {
            [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.updatePlayerUI(withCurrentTime: CGFloat(seconds))
        }

        self.audioPlayer.play()
    }
    
    
    // update the slider position and the timer text
    func updatePlayerUI(withCurrentTime currentTime: CGFloat) {
        circularSlider.endPointValue = currentTime
        let components = NSDateComponents()
        components.second = Int(currentTime)
        timerLabel.text = dateComponentsFormatter.stringFromDateComponents(components)
    }
    
    func updateTimer() {
        let components = NSDateComponents()
        components.second = Int(circularSlider.endPointValue)
        timerLabel.text = dateComponentsFormatter.stringFromDateComponents(components)
    }
    
    // MARK: - Notification 
    
    func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seekToTime(kCMTimeZero)
            playerSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
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
