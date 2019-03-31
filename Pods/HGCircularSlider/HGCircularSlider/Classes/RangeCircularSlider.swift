//
//  RangeCircularSlider.swift
//  Pods
//
//  Created by Hamza Ghazouani on 25/10/2016.
//
//

import UIKit

/**
 A visual control used to select a range of values (between start point and the end point) from a continuous range of values.
 RangeCircularSlider use the target-action mechanism to report changes made during the course of editing:
 ValueChanged, EditingDidBegin and EditingDidEnd
 */
open class RangeCircularSlider: CircularSlider {

    public enum SelectedThumb {
        case startThumb
        case endThumb
        case none

        var isStart: Bool {
            return  self == SelectedThumb.startThumb
        }
        var isEnd: Bool {
            return  self == SelectedThumb.endThumb
        }
    }

    // MARK: Changing the Slider’s Appearance
    
    /**
     * The color used to tint start thumb
     * Ignored if the startThumbImage != nil
     *
     * The default value of this property is the groupTableViewBackgroundColor.
     */
    @IBInspectable
    open var startThumbTintColor: UIColor = UIColor.groupTableViewBackground
    
    /**
     * The color used to tint the stroke of the start thumb
     * Ignored if the startThumbImage != nil
     *
     * The default value of this property is the green color.
     */
    @IBInspectable
    open var startThumbStrokeColor: UIColor = UIColor.green
    
    /**
     * The stroke highlighted color of start thumb
     * The default value of this property is blue color
     */
    @IBInspectable
    open var startThumbStrokeHighlightedColor: UIColor = UIColor.purple
    
    
    /**
     * The image of the end thumb
     * Clears any custom color you may have provided for end thumb.
     *
     * The default value of this property is nil
     */
    open var startThumbImage: UIImage?
    
    
    // MARK: Accessing the Slider’s Value Limits
    
    /**
     * The minimum value of the receiver.
     *
     * If you change the value of this property, and the start value of the receiver is below the new minimum, the start value is adjusted to match the new minimum value automatically.
     * The end value is also adjusted to match (startPointValue + distance) automatically if the distance is different to -1 (SeeAlso: startPointValue, distance)
     * The default value of this property is 0.0.
     */
    override open var minimumValue: CGFloat {
        didSet {
            if startPointValue < minimumValue {
                startPointValue = minimumValue
            }
        }
    }
    
    /**
     * The maximum value of the receiver.
     *
     * If you change the value of this property, and the end value of the receiver is above the new maximum, the end value is adjusted to match the new maximum value automatically.
     * The start value is also adjusted to match (endPointValue - distance) automatically  if the distance is different to -1 (see endPointValue, distance)
     * The default value of this property is 1.0.
     */
    @IBInspectable
    override open var maximumValue: CGFloat {
        didSet {
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
        }
    }
    
    /**
    * The fixed distance between the start value and the end value
    *
    * If you change the value of this property, the end value is adjusted to match (startPointValue + distance)
    * If the end value is above the maximum value, the end value is adjusted to match the maximum value and the start value is adjusted to match (endPointValue - distance)
    * To disable distance use -1 (by default)
    *
    * The default value of this property is -1
    */
    @IBInspectable
    open var distance: CGFloat = -1 {
        didSet {
            assert(distance <= maximumValue - minimumValue, "The distance value is greater than distance between max and min value")
            endPointValue = startPointValue + distance
        }
    }
    
    
    /**
     * The value in the start thumb.
     *
     * If you try to set a value that is below the minimum value, the minimum value is set instead.
     * If you try to set a value that is above the (endPointValue - distance), the (endPointValue - distance) is set instead.
     *
     * The default value of this property is 0.0.
     */
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
    
    /**
     * The value in the end thumb.
     *
     * If you try to set a value that is above the maximum value, the maximum value is set instead.
     * If you try to set a value that is below the (startPointValue + distance), the (startPointValue + distance) is set instead.
     *
     * The default value of this property is 0.5
     */
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
    
    // MARK: private properties / methods
    
    /**
     * The center of the start thumb
     * Used to know in which thumb is the user gesture
     */
    fileprivate var startThumbCenter: CGPoint = CGPoint.zero
    
    /**
     * The center of the end thumb
     * Used to know in which thumb is the user gesture
     */
    fileprivate var endThumbCenter: CGPoint = CGPoint.zero
    
    /**
     * The last touched thumb
     * By default the value is none
     */
    fileprivate var selectedThumb: SelectedThumb = .none
    
    /**
     Checks if the touched point affect the thumb
     
     The point affect the thumb if :
     The thumb rect contains this point
     Or the angle between the touched point and the center of the thumb less than 15°
     
     - parameter thumbCenter: the center of the thumb
     - parameter touchPoint:  the touched point
     
     - returns: true if the touched point affect the thumb, false if not.
     */
    internal func isThumb(withCenter thumbCenter: CGPoint, containsPoint touchPoint: CGPoint) -> Bool {
        // the coordinates of thumb from its center
        let rect = CGRect(x: thumbCenter.x - thumbRadius, y: thumbCenter.y - thumbRadius, width: thumbRadius * 2, height: thumbRadius * 2)
        if rect.contains(touchPoint) {
            return true
        }
        
        let angle = CircularSliderHelper.angle(betweenFirstPoint: thumbCenter, secondPoint: touchPoint, inCircleWithCenter: bounds.center)
        let degree =  CircularSliderHelper.degrees(fromRadians: angle)
        
        // tolerance 15°
        let isInside = degree < 15 || degree > 345
        return isInside
    }
    
    // MARK: Drawing
    
    /**
     See superclass documentation
     */
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
        endThumbTintColor.setFill()
        (isHighlighted == true && selectedThumb == .endThumb) ? endThumbStrokeHighlightedColor.setStroke() : endThumbStrokeColor.setStroke()
        endThumbCenter = drawThumb(withAngle: endAngle, inContext: context)
        if let image = endThumbImage {
            endThumbCenter = drawThumb(withImage: image, angle: endAngle, inContext: context)
        }
        
        // start thumb
        startThumbTintColor.setFill()
        (isHighlighted == true && selectedThumb == .startThumb) ? startThumbStrokeHighlightedColor.setStroke() : startThumbStrokeColor.setStroke()

        startThumbCenter = drawThumb(withAngle: startAngle, inContext: context)
        if let image = startThumbImage {
            startThumbCenter = drawThumb(withImage: image, angle: startAngle, inContext: context)
        }
    }
    
    // MARK: User interaction methods
    
    /**
     See superclass documentation
     */
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        sendActions(for: .editingDidBegin)
        // the position of the pan gesture
        let touchPosition = touch.location(in: self)
        selectedThumb = thumb(for: touchPosition)

        return selectedThumb != .none
    }
    
    /**
     See superclass documentation
     */
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard selectedThumb != .none else {
            return false
        }

        // the position of the pan gesture
        let touchPosition = touch.location(in: self)
        let startPoint = CGPoint(x: bounds.center.x, y: 0)
        
        let oldValue: CGFloat = selectedThumb.isStart ? startPointValue : endPointValue
        let value =  newValue(from: oldValue, touch: touchPosition, start: startPoint)
        
        if selectedThumb.isStart {
            startPointValue = value
        } else {
            endPointValue = value
        }
        sendActions(for: .valueChanged)
        
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
    }


    // MARK: - Helpers
    open func thumb(for touchPosition: CGPoint) -> SelectedThumb {
        if isThumb(withCenter: startThumbCenter, containsPoint: touchPosition) {
            return .startThumb
        }
        else if isThumb(withCenter: endThumbCenter, containsPoint: touchPosition) {
            return .endThumb
        } else {
            return .none
        }
    }

}
