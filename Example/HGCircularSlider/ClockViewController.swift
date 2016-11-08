//
//  ViewController.swift
//  HGCircularSlider
//
//  Created by Hamza Ghazouani on 10/19/2016.
//  Copyright (c) 2016 Hamza Ghazouani. All rights reserved.
//

import UIKit
import HGCircularSlider

extension NSDate {
    
}

class ClockViewController: UIViewController {
    
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var bedtimeLabel: UILabel!
    @IBOutlet weak var wakeLabel: UILabel!
    @IBOutlet weak var rangeCircularSlider: RangeCircularSlider!
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup O'clock
        rangeCircularSlider.startThumbImage = UIImage(named: "Bedtime")
        rangeCircularSlider.endThumbImage = UIImage(named: "Wake")
        
        let dayInSeconds = 24 * 60 * 60
        rangeCircularSlider.maximumValue = CGFloat(dayInSeconds)
        
        rangeCircularSlider.startPointValue = 1 * 60 * 60
        rangeCircularSlider.endPointValue = 8 * 60 * 60

        updateTexts(rangeCircularSlider)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateTexts(sender: AnyObject) {
        let bedtime = NSTimeInterval(rangeCircularSlider.startPointValue)
        let bedtimeDate = NSDate(timeIntervalSinceReferenceDate: bedtime)
        bedtimeLabel.text = dateFormatter.stringFromDate(bedtimeDate)
        
        let wake = NSTimeInterval(rangeCircularSlider.endPointValue)
        let wakeDate = NSDate(timeIntervalSinceReferenceDate: wake)
        wakeLabel.text = dateFormatter.stringFromDate(wakeDate)
        
        let duration = wake - bedtime
        let durationDate = NSDate(timeIntervalSinceReferenceDate: duration)
        dateFormatter.dateFormat = "HH:mm"
        durationLabel.text = dateFormatter.stringFromDate(durationDate)
        dateFormatter.dateFormat = "hh:mm a"
    }
}

