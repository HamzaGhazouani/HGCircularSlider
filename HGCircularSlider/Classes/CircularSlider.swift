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
 * CircularSlider uses the target-action mechanism to report changes made during the course of editing:
 * ValueChanged, EditingDidBegin and EditingDidEnd
 */
@IBDesignable
open class CircularSlider: UIControl {
    
    // MARK: Changing the Slider’s Appearance
    
    /**
     * The color shown for the selected portion of the slider disk. (between start and end values)
     * The default value is a transparent color.
     */
    @IBInspectable
    open var diskFillColor: UIColor = .clear
    
    /**
     * The color shown for the unselected portion of the slider disk. (outside start and end values)
     * The default value of this property is the black color with alpha = 0.3.
     */
    @IBInspectable
    open var diskColor: UIColor = .gray
    
    /**
     * The color shown for the selected track portion. (between start and end values)
     * The default value of this property is the tint color.
     */
    @IBInspectable
    open var trackFillColor: UIColor = .clear
    
    /**
     * The color shown for the unselected track portion. (outside start and end values)
     * The default value of this property is the white color.
     */
    @IBInspectable
    open var trackColor: UIColor = .white
    
    /**
     * The width of the circular line
     *
     * The default value of this property is 5.0.
     */
    @IBInspectable
    open var lineWidth: CGFloat = 5.0

    /**
     * The width of the unselected track portion of the slider
     *
     * The default value of this property is 5.0.
     */
    @IBInspectable
    open var backtrackLineWidth: CGFloat = 5.0

    /**
     * The shadow offset of the slider
     *
     * The default value of this property is .zero.
     */
    @IBInspectable
    open var trackShadowOffset: CGPoint = .zero

    /**
     * The color of the shadow offset of the slider
     *
     * The default value of this property is .gray.
     */
    @IBInspectable
    open var trackShadowColor: UIColor = .gray

    /**
     * The width of the thumb stroke line
     *
     * The default value of this property is 4.0.
     */
    @IBInspectable
    open var thumbLineWidth: CGFloat = 4.0
    
    /**
     * The radius of the thumb
     *
     * The default value of this property is 13.0.
     */
    @IBInspectable
    open var thumbRadius: CGFloat = 13.0
    
    /**
     * The color used to tint the thumb
     * Ignored if the endThumbImage != nil
     *
     * The default value of this property is the groupTableViewBackgroundColor.
     */
    @IBInspectable
    open var endThumbTintColor: UIColor = .groupTableViewBackground
    
    /**
     * The stroke highlighted color of the end thumb
     * The default value of this property is blue
     */
    @IBInspectable
    open var endThumbStrokeHighlightedColor: UIColor = .blue
    
    /**
     * The color used to tint the stroke of the end thumb
     * Ignored if the endThumbImage != nil
     *
     * The default value of this property is red.
     */
    @IBInspectable
    open var endThumbStrokeColor: UIColor = .red
    
    /**
     * The image of the end thumb
     * Clears any custom color you may have provided for the end thumb.
     *
     * The default value of this property is nil
     */
    open var endThumbImage: UIImage?
    
    // MARK: Accessing the Slider’s Value Limits
    
    /**
     * Fixed number of rounds - how many circles has user to do to reach max value (like apple bedtime clock - which have 2)
     * the default value if this property is 1
     */
    @IBInspectable
    open var numberOfRounds: Int = 1 {
        didSet {
            assert(numberOfRounds > 0, "Number of rounds has to be positive value!")
            setNeedsDisplay()
        }
    }
    
    /**
     * The minimum value of the receiver.
     *
     * If you change the value of this property, and the end value of the receiver is below the new minimum, the end point value is adjusted to match the new minimum value automatically.
     * The default value of this property is 0.0.
     */
    @IBInspectable
    open var minimumValue: CGFloat = 0.0 {
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
    open var maximumValue: CGFloat = 1.0 {
        didSet {
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
        }
    }

    /**
    * The offset of the thumb centre from the circle.
    *
    * You can use this to move the thumb inside or outside the circle of the slider
    * If the value is grather than 0 the thumb will be displayed outside the cirlce
    * And if the value is negative, the thumb will be displayed inside the circle 
    */
    @IBInspectable
    open var thumbOffset: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /**
    * Stop the thumb going beyond the min/max.
    *
    */
    @IBInspectable
    open var stopThumbAtMinMax: Bool = false


    /**
     * The value of the endThumb (changed when the user change the position of the end thumb)
     *
     * If you try to set a value that is above the maximum value, the property automatically resets to the maximum value.
     * And if you try to set a value that is below the minimum value, the property automatically resets  to the minimum value.
     *
     * The default value of this property is 0.5
     */
    open var endPointValue: CGFloat = 0.5 {
        didSet {
            if oldValue == endPointValue {
                return
            }
            if endPointValue > maximumValue {
                endPointValue = maximumValue
            }
            else if endPointValue < minimumValue {
                endPointValue = minimumValue
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
            
            // if we use an image for the thumb, the radius of the image will be used
            let maxThumbRadius = max(thumbRadius, (self.endThumbImage?.size.height ?? 0) / 2)

            // all elements should be inside the view rect, for that we should subtract the highest value between the radius of thumb and the line width
            radius -= max(lineWidth, (maxThumbRadius + thumbLineWidth + thumbOffset))
            return radius
        }
    }
    
    ///  See superclass documentation
    override open var isHighlighted: Bool {
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
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCircularSlider(inContext: context)
        
        let valuesInterval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        // get end angle from end value
        let endAngle = CircularSliderHelper.scaleToAngle(value: endPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle
        
        drawFilledArc(fromAngle: CircularSliderHelper.circleInitialAngle, toAngle: endAngle, inContext: context)
        
        // draw end thumb
        endThumbTintColor.setFill()
        (isHighlighted == true) ? endThumbStrokeHighlightedColor.setStroke() : endThumbStrokeColor.setStroke()
        
        drawThumbAt(endAngle, with: endThumbImage, inContext: context)
    }
    
    // MARK: User interaction methods
    
    /**
     See superclass documentation
     */
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        sendActions(for: .editingDidBegin)
        
        return true
    }
    
    /**
     See superclass documentation
     */
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // the position of the pan gesture
        let touchPosition = touch.location(in: self)
        let startPoint = CGPoint(x: bounds.center.x, y: 0)
        let value = newValue(from: endPointValue, touch: touchPosition, start: startPoint)
        
        endPointValue = value
        sendActions(for: .valueChanged)
        
        return true
    }
    
    /**
     See superclass documentation
     */
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        sendActions(for: .editingDidEnd)
    }

    // MARK: Utilities methods
    internal func newValue(from oldValue: CGFloat, touch touchPosition: CGPoint, start startPosition: CGPoint) -> CGFloat {
        let angle = CircularSliderHelper.angle(betweenFirstPoint: startPosition, secondPoint: touchPosition, inCircleWithCenter: bounds.center)
        let interval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        let deltaValue = CircularSliderHelper.delta(in: interval, for: angle, oldValue: oldValue)
        
        var newValue = oldValue + deltaValue
        let range = maximumValue - minimumValue

        if !stopThumbAtMinMax {
            if newValue > maximumValue {
                newValue -= range
            }
            else if newValue < minimumValue {
                newValue += range
            }
        }

        return newValue
    }
    
    
    
}
