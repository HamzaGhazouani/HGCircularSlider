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
public class MidPointCircularSlider: RangeCircularSlider {
    
    // MARK: properties 
    
    /**
     * The color used to tint thumb
     * Ignored if the midThumbImage != nil
     *
     * The default value of this property is the groupTableViewBackgroundColor.
     */
    @IBInspectable
    public var midThumbTintColor: UIColor = UIColor.groupTableViewBackgroundColor()
    
    /**
     * The stroke highlighted color of end thumb
     * The default value of this property is blue color
     */
    @IBInspectable
    public var midThumbStrokeHighlightedColor: UIColor = UIColor.blueColor()
    
    /**
     * The color used to tint the stroke of the mid thumb
     * Ignored if the midThumbImage != nil
     *
     * The default value of this property is the red color.
     */
    @IBInspectable
    public var midThumbStrokeColor: UIColor = UIColor.redColor()
    
    
    /**
     * The image of the mid thumb
     * Clears any custom color you may have provided for mid thumb.
     *
     * The default value of this property is nil
     */
    public var midThumbImage: UIImage?
    
    
    /**
     * The fixed range distance
     *
     * The value of this property should be >= 0
     * The default value of this property is 0.2
     */
    override public var distance: CGFloat {
        didSet {
            assert(distance >= 0, "The CustomCircularSlider works only with fixed distance between start and end points, so distance property should be > 0")
        }
    }
    
    /// The value of the mid point (between the start and end points)
    private var midPointValue: CGFloat  {
        get {
            return (endPointValue + startPointValue) / 2
        }
        set {
            let value = newValue
            print("\(newValue)")
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
    
    /**
     See superclass documentation
     */
    override public func drawRect(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCircularSlider(inContext: context)
        
        let valuesInterval = Interval(min: minimumValue, max: maximumValue)
        
        // get start angle from start value
        let startAngle = CircularSliderHelper.scaleToAngle(value: startPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle
        // get end angle from end value
        let endAngle = CircularSliderHelper.scaleToAngle(value: endPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle
        
        let midAngle = CircularSliderHelper.scaleToAngle(value: midPointValue, inInterval: valuesInterval) + CircularSliderHelper.circleInitialAngle

        drawFilledArc(fromAngle: startAngle, toAngle: endAngle, inContext: context)
        
        // draw mid thumb
        midThumbTintColor.setFill()
        (highlighted == true) ? midThumbStrokeHighlightedColor.setStroke() : midThumbStrokeColor.setStroke()
        
        guard let image = midThumbImage else {
            drawThumb(withAngle: midAngle, inContext: context)
            return
        }
        drawThumb(withImage: image, angle: midAngle, inContext: context)
    }
    
    // MARK: user interaction 
    
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
        let touchPosition = touch.locationInView(self)

        let center = CGPointMake(bounds.midX, bounds.midY)
        let startPoint = CGPoint(x: center.x, y: 0)
        let angle = CircularSliderHelper.angle(betweenFirstPoint: startPoint, secondPoint: touchPosition, inCircleWithCenter: center)
        
        let interval = Interval(min: minimumValue, max: maximumValue)
        let newValue = CircularSliderHelper.value(inInterval: interval, fromAngle: angle)
        

        midPointValue = newValue
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
}
