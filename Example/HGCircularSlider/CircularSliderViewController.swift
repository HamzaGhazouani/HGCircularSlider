//
//  CircularSliderViewController.swift
//  HGCircularSlider
//
//  Created by Hamza Ghazouani on 16/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import HGCircularSlider

class CircularSliderViewController: UIViewController {

    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        circularSlider.endPointValue = 1
        updateTexts()
        circularSlider.addTarget(self, action: #selector(updateTexts), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateTexts() {
        let value = circularSlider.endPointValue
        let ok = (circularSlider.maximumValue  / CGFloat(circularSlider.numberOfRounds))
        let ff = ceil(value / ok)
        
        maxValueLabel.text = String(format: "%.0f", circularSlider.maximumValue)
        minValueLabel.text = String(format: "%.0f", circularSlider.minimumValue)
        
        currentValueLabel.text = String(format: "%.0f", value)
        roundsLabel.text = "Round N° " +  String(format: "%.0f", ff)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
