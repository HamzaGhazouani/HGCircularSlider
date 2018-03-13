//
//  CircularProgressView.swift
//  HGCircularSlider
//
//  Created by Saman kumara on 3/9/18.
//  Copyright © 2018 intive. All rights reserved.
//

import UIKit


open class CircularProgressView: CircularSlider {
    
    /**
     * The center of the end thumb
     * Used to know in which thumb is the user gesture
     */
    fileprivate var endThumbCenter: CGPoint = CGPoint.zero
    fileprivate var endLabelCenter: CGPoint = CGPoint.zero

    /**
     * If this is true the end thumb will be displyed
     *
     * The default value of this property is the false.
     */
    @IBInspectable
    open var showEndThumb: Bool = false
    
    /**
     * The color used to progress value label text color
     *
     * The default value of this property is the white color.
     */
    @IBInspectable
    open var progressLabelColor: UIColor = UIColor.white
    
    /**
     * The progress value label text font name
     *
     * The default value of this property is the Helvetica.
     */
    @IBInspectable
    open var progressLabelFontName: String = "Helvetica"
    
    /**
     * The progress value label text font size
     *
     * The default value of this property is the 12.0.
     */
    @IBInspectable
    open var progressLabelFontSize: CGFloat = 12.0
    
    @IBInspectable
    open var distance: CGFloat = -1 {
        didSet {
            assert(distance <= maximumValue - minimumValue, "The distance value is greater than distance between max and min value")
            endPointValue = startPointValue + distance
        }
    }
    
    open var startPointValue: CGFloat = 0.0 {
        didSet {
            guard oldValue != startPointValue else { return }
            
            if startPointValue < minimumValue {
                startPointValue = minimumValue
            }
            
            if distance > 0 {
                endPointValue = startPointValue + distance
            }
            
            setNeedsDisplay()
        }
    }
    
    override open var endPointValue: CGFloat {
        didSet {
            if oldValue == endPointValue && distance <= 0 {
                return
            }
            
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
            
            if distance > 0 {
                startPointValue = endPointValue - distance
            }
            
            setNeedsDisplay()
        }
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCircularSlider(inContext: context)
        
        let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        // get start angle from start value
        let startAngle = CircularSliderHelper.scaleToAngle(value: startPointValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
        // get end angle from end value
        let endAngle = CircularSliderHelper.scaleToAngle(value: endPointValue, inInterval: interval) + CircularSliderHelper.circleInitialAngle
        
        drawShadowArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
        drawFilledArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
        
        // end thumb
        if (showEndThumb) {
            endThumbTintColor.setFill()
            endThumbCenter = drawThumb(withAngle: endAngle, inContext: context)
            if let image = endThumbImage {
                endThumbCenter = drawThumb(withImage: image, angle: endAngle, inContext: context)
            }
        }
        
        endLabelCenter = drawLable(withAngle: endAngle, labelFont:  UIFont(name: progressLabelFontName, size: progressLabelFontSize)!, labelFontColor: progressLabelColor, inContext: context)
    }
}
