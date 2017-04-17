//
//  MidPointCircularSlider.swift
//  Pods
//
//  Created by Hamza Ghazouani on 04/11/2016.
//
//

/**
 A visual control used to select a fixed range of values from a continuous range of values.
 MidPointCircularSlider use the target-action mechanism to report changes made during the course of editing:
 ValueChanged, EditingDidBegin and EditingDidEnd
 */
open class MidPointCircularSlider: RangeCircularSlider {
    
    // MARK: properties 
    
    /**
     * The color used to tint thumb
     * Ignored if the midThumbImage != nil
     *
     * The default value of this property is the groupTableViewBackgroundColor.
     */
    @IBInspectable
    open var midThumbTintColor: UIColor = UIColor.groupTableViewBackground
    
    /**
     * The stroke highlighted color of end thumb
     * The default value of this property is blue color
     */
    @IBInspectable
    open var midThumbStrokeHighlightedColor: UIColor = UIColor.blue
    
    /**
     * The color used to tint the stroke of the mid thumb
     * Ignored if the midThumbImage != nil
     *
     * The default value of this property is the red color.
     */
    @IBInspectable
    open var midThumbStrokeColor: UIColor = UIColor.red
    
    
    /**
     * The image of the mid thumb
     * Clears any custom color you may have provided for mid thumb.
     *
     * The default value of this property is nil
     */
    open var midThumbImage: UIImage?
    
    
    /**
     * The fixed range distance
     *
     * The value of this property should be >= 0
     * The default value of this property is 0.2
     */
    override open var distance: CGFloat {
        didSet {
            assert(distance >= 0, "The MidPointCircularSlider works only with fixed distance between start and end points, so distance property should be > 0")
            endPointValue = startPointValue + distance
        }
    }
    
    /**
     * The value of the mid point (between the start and end points)
     */
    open var midPointValue: CGFloat  {
        get {
            return (endPointValue + startPointValue) / 2
        }
        set {
            let value = newValue

            let interval = (endPointValue - startPointValue) / 2
            startPointValue = value - interval
            endPointValue = value + interval
        }
    }
    
    // MARK: init methods
    
    /**
     See superclass documentation
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        distance = 0.2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distance = 0.2
    }
    
    /**
     See superclass documentation
     */
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCircularSlider(inContext: context)
        
        let valuesInterval = Interval(min: minimumValue, max: maximumValue, rounds: numberOfRounds)
        
        // get start angle from start value
        let startAngle = CircularSliderHelper.scaleToAngle(value: startPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle
        // get end angle from end value
        let endAngle = CircularSliderHelper.scaleToAngle(value: endPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle
        
        let midAngle = CircularSliderHelper.scaleToAngle(value: midPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle

        drawFilledArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
        
        // draw mid thumb
        midThumbTintColor.setFill()
        (isHighlighted == true) ? midThumbStrokeHighlightedColor.setStroke() : midThumbStrokeColor.setStroke()
        
        guard let image = midThumbImage else {
           drawThumb(withAngle: midAngle, inContext: context)
            return
        }
        drawThumb(withImage: image, angle: midAngle, inContext: context)
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
        let touchPosition = touch.location(in: self)

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startPoint = CGPoint(x: center.x, y: 0)
        let value = newValue(from: midPointValue, touch: touchPosition, start: startPoint)
        
        midPointValue = value
        sendActions(for: .valueChanged)
        
        return true
    }
    
}
