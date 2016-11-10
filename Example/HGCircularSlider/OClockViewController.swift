//
//  OClockViewController.swift
//  HGCircularSlider
//
//  Created by Hamza Ghazouani on 09/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import HGCircularSlider

class OClockViewController: UIViewController {

    @IBOutlet weak var minutesCircularSlider: CircularSlider!
    @IBOutlet weak var hoursCircularSlider: CircularSlider!
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var AMPMLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSliders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSliders() {
        // hours
        hoursCircularSlider.minimumValue = 0
        hoursCircularSlider.maximumValue = 12
        hoursCircularSlider.endPointValue = 6
        hoursCircularSlider.addTarget(self, action: #selector(updateHours), for: .valueChanged)
        
        // minutes
        minutesCircularSlider.minimumValue = 0
        minutesCircularSlider.maximumValue = 60
        minutesCircularSlider.endPointValue = 35
        minutesCircularSlider.addTarget(self, action: #selector(updateMinutes), for: .valueChanged)

        
    }
    
    // MARK: user interaction methods 
    
    // TODO: the thumb of hoursSlider should get only Int values (slide directly from 3 to 4, from 4 to 5, etc)
    func updateHours() {
     var selectedHour = Int(hoursCircularSlider.endPointValue)
        // TODO: use date formatter
        selectedHour = selectedHour == 0 ? 12 : selectedHour
        
        // TODO: remove that 
        if hoursCircularSlider.endPointValue > (CGFloat(selectedHour) + 0.5) && minutesCircularSlider.endPointValue > 30 {
            selectedHour += 1
        }
        
        hoursLabel.text = String(selectedHour)
    }
    
    func updateMinutes() {
        let selectedMinute = Int(minutesCircularSlider.endPointValue)
        minutesLabel.text = String(format: "%02d", selectedMinute)
       
        // TODO: remove that
        updateHours()
    }

    @IBAction func switchBetweenAMAndPM(_ sender: UISegmentedControl) {
        AMPMLabel.text = sender.selectedSegmentIndex == 0 ? "AM" : "PM"
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
