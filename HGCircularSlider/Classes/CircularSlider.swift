//
//  CircularSlider.swift
//  Pods
//
//  Created by Hamza Ghazouani on 19/10/2016.
//
//

import UIKit

/**
 * A visual control used to select a single value from a continuous range of values.
 * Can also be used like a circular progress view
 * CircularSlider use the target-action mechanism to report changes made during the course of editing:
 * ValueChanged, EditingDidBegin and EditingDidEnd
 */
@IBDesignable
public class CircularSlider: UIControl {
    
    // MARK: Changing the Slider’s Appearance
    
    /**
     * The color shown for the portion of the disk of slider that is filled. (between start and end values)
     * The default value is a transparent color.
     */
    @IBInspectable
    public var diskFillColor: UIColor = UIColor.clearColor()
    
    /**
     * The color shown for the portion of the disk of slider that is unfilled. (outside start and end values)
     * The default value of this property is the black color with alpha = 0.3.
     */
    @IBInspectable
    public var diskColor: UIColor = UIColor.grayColor()
    
    /**
     * The color shown for the portion of the slider that is filled. (between start and end values)
     * The default value of this property is the tint color.
     */
    @IBInspectable
    public var trackFillColor: UIColor = UIColor.clearColor()
    
    /**
     * The color shown for the portion of the slider that is unfilled. (outside start and end values)
     * The default value of this property is the white color.
     */
    @IBInspectable
    public var trackColor: UIColor = UIColor.whiteColor()
    
    /**
     * The width of the circular line
     *
     * The default value of this property is 5.0.
     */
    @IBInspectable
    public var lineWidth: CGFloat = 5.0
    
    /**
     * The width of the thumb stroke line
     *
     * The default value of this property is 4.0.
     */
    @IBInspectable
    public var thumbLineWidth: CGFloat = 4.0
    
    /**
     * The radius of thumb
     *
     * The default value of this property is 13.0.
     */
    @IBInspectable
    public var thumbRadius: CGFloat = 13.0
    
    /**
     * The color used to tint thumb
     * Ignored if the endThumbImage != nil
     *
     * The default value of this property is the groupTableViewBackgroundColor.
     */
    @IBInspectable
    public var endThumbTintColor: UIColor = UIColor.groupTableViewBackgroundColor()
    
    /**
     * The stroke highlighted color of end thumb
     * The default value of this property is blue color
     */
    @IBInspectable
    public var endThumbStrokeHighlightedColor: UIColor = UIColor.blueColor()
    
    /**
     * The color used to tint the stroke of the end thumb
     * Ignored if the endThumbImage != nil
     *
     * The default value of this property is the red color.
     */
    @IBInspectable
    public var endThumbStrokeColor: UIColor = UIColor.redColor()
    
    /**
     * The image of the end thumb
     * Clears any custom color you may have provided for end thumb.
     *
     * The default value of this property is nil
     */
    public var endThumbImage: UIImage?
    
    // MARK: Accessing the Slider’s Value Limits
    
    /**
     * The minimum value of the receiver.
     *
     * If you change the value of this property, and the end value of the receiver is below the new minimum, the end point value is adjusted to match the new minimum value automatically.
     * The default value of this property is 0.0.
     */
    @IBInspectable
    public var minimumValue: CGFloat = 0.0 {
        didSet {
            if endPointValue < minimumValue {
                endPointValue = minimumValue
            }
        }
    }
    
    /**
     * The maximum value of the receiver.
     *
     * If you change the value of this property, and the end value of the receiver is above the new maximum, the end value is adjusted to match the new maximum value automatically.
     * The default value of this property is 1.0.
     */
    @IBInspectable
    public var maximumValue: CGFloat = 1.0 {
        didSet {
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
        }
    }
    
    /**
     * The value of the endThumb (changed when the user change the position of the end thumb)
     *
     * If you try to set a value that is above the maximum value, the maximum value is set instead.
     * If you try to set a value that is below the minimum value, the minimum value is set instead.
     *
     * The default value of this property is 0.5
     */
    public var endPointValue: CGFloat = 0.5 {
        didSet {            
            if oldValue == endPointValue {
                return
            }
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
            
            setNeedsDisplay()
        }
    }
    
    /**
     * The radius of circle
     */
    internal var radius: CGFloat {
        get {
            // the minimum between the height/2 and the width/2
            var radius =  min(bounds.center.x, bounds.center.y)
            // all elements should be inside the view rect, for that we should subtract the highest value between the radius of thumb and the line width
            radius -= max(lineWidth, (thumbRadius + thumbLineWidth))
            return radius
        }
    }
    
    ///  See superclass documentation
    override public var highlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: init methods
    
    /**
     See superclass documentation
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    /**
     See superclass documentation
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    internal func setup() {
        trackFillColor = tintColor
    }
    
    // MARK: Drawing methods
    
    /**
     See superclass documentation
     */
    override public func drawRect(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCircularSlider(inContext: context)
        
        let valuesInterval = Interval(min: minimumValue, max: maximumValue)
        // get end angle from end value
        let endAngle = CircularSliderHelper.scaleToAngle(value: endPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle
        
        drawFilledArc(fromAngle: CircularSliderHelper.circleInitialAngle, toAngle: endAngle, inContext: context)
        
        // draw end thumb
        endThumbTintColor.setFill()
        (highlighted == true) ? endThumbStrokeHighlightedColor.setStroke() : endThumbStrokeColor.setStroke()
        drawThumb(withAngle: endAngle, inContext: context)
        
        guard let image = endThumbImage else {
            drawThumb(withAngle: endAngle, inContext: context)
            return
        }
        drawThumb(withImage: image, angle: endAngle, inContext: context)
    }
    
    // MARK: User interaction methods
    
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
