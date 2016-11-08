//
//  CircularSlider+Touch.swift
//  Pods
//
//  Created by Hamza Ghazouani on 26/10/2016.
//
//

import UIKit

extension CircularSlider {

    // MARK: user interaction methods
    
    /**
     See superclass documentation
     */
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        sendActionsForControlEvents(.EditingDidBegin)
        
        return true
    }
    
    /**
     See superclass documentation
     */
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        // the position of the pan gesture
        let touchPosition = touch.locationInView(self)
        
        let startPoint = CGPoint(x: bounds.center.x, y: 0)
        let angle = CircularSliderHelper.angle(betweenFirstPoint: startPoint, secondPoint: touchPosition, inCircleWithCenter: bounds.center)
        
        let interval = Interval(min: minimumValue, max: maximumValue)
        let newValue = CircularSliderHelper.value(inInterval: interval, fromAngle: angle)
        
        endPointValue = newValue
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    /**
     See superclass documentation
     */
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        sendActionsForControlEvents(.EditingDidEnd)
    }
}
