//
//  CircularSlider+Draw.swift
//  Pods
//
//  Created by Hamza Ghazouani on 21/10/2016.
//
//

import UIKit

extension CircularSlider {
    
    /**
     Draw arc with stroke mode (Stroke) or Disk (Fill) or both (FillStroke) mode
     FillStroke used by default
     
     - parameter arc:           the arc coordinates (origin, radius, start angle, end angle)
     - parameter lineWidth:     the with of the circle line (optional) by default 2px
     - parameter mode:          the mode of the path drawing (optional) by default FillStroke
     - parameter context:       the context
     
     */
    internal static func drawArc(withArc arc: Arc, lineWidth: CGFloat = 2, mode: CGPathDrawingMode = .FillStroke, inContext context: CGContextRef) {
        
        let circle = arc.circle
        let origin = circle.origin
        
        UIGraphicsPushContext(context)
        CGContextBeginPath(context)
        
        CGContextSetLineWidth(context, lineWidth)
        CGContextAddArc(context, origin.x, origin.y, circle.radius, arc.startAngle, arc.endAngle, 0)
        CGContextMoveToPoint(context, origin.x, origin.y)
        CGContextDrawPath(context, mode)
        UIGraphicsPopContext()
    }
    
    /**
     Draw disk using arc coordinates
     
     - parameter arc:     the arc coordinates (origin, radius, start angle, end angle)
     - parameter context: the context
     */
    internal static func drawDisk(withArc arc: Arc, inContext context: CGContextRef) {
        
        let circle = arc.circle
        let origin = circle.origin
        
        UIGraphicsPushContext(context)
        CGContextBeginPath(context)
        
        CGContextSetLineWidth(context, 0)
        CGContextAddArc(context, origin.x, origin.y, circle.radius, arc.startAngle, arc.endAngle, 0)
        CGContextAddLineToPoint(context, origin.x, origin.y)
        CGContextDrawPath(context, .Fill)
        UIGraphicsPopContext()
    }
    
    // MARK: drawing instance methods
    
    /// Draw the circular slider
    internal func drawCircularSlider(inContext context: CGContextRef) {
        diskColor.setFill()
        trackColor.setStroke()
        
        
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let sliderArc = Arc(circle: circle, startAngle: CircularSliderHelper.circleMinValue, endAngle: CircularSliderHelper.circleMaxValue)
        CircularSlider.drawArc(withArc: sliderArc, lineWidth: lineWidth, inContext: context)
    }
    
    /// draw Filled arc between start an end angles
    internal func drawFilledArc(fromAngle startAngle: CGFloat, toAngle endAngle: CGFloat, inContext context: CGContextRef) {
        diskFillColor.setFill()
        trackFillColor.setStroke()
        
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let arc = Arc(circle: circle, startAngle: startAngle, endAngle: endAngle)
        
        // fill Arc
        CircularSlider.drawDisk(withArc: arc, inContext: context)
        // stroke Arc
        CircularSlider.drawArc(withArc: arc, lineWidth: lineWidth, mode: .Stroke, inContext: context)
    }
    
    
    /**
     Draw the thumb and return the coordinates of its center
     
     - parameter angle:   the angle of the point in the main circle
     - parameter context: the context
     
     - returns: return the origin point of the thumb
     */
    internal func drawThumb(withAngle angle: CGFloat, inContext context: CGContextRef) -> CGPoint {
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let thumbOrigin = CircularSliderHelper.endPoint(fromCircle: circle, angle: angle)
        let thumbCircle = Circle(origin: thumbOrigin, radius: thumbRadius)
        let thumbArc = Arc(circle: thumbCircle, startAngle: CircularSliderHelper.circleMinValue, endAngle: CircularSliderHelper.circleMaxValue)
        
        CircularSlider.drawArc(withArc: thumbArc, lineWidth: thumbLineWidth, inContext: context)
        return thumbOrigin
    }
    
    
    /**
     Draw thumb using image and return the coordinates of its center

     - parameter image:   the image of the thumb
     - parameter angle:   the angle of the point in the main circle
     - parameter context: the context
     
     - returns: return the origin point of the thumb
     */
    internal func drawThumb(withImage image: UIImage, angle: CGFloat, inContext context: CGContextRef) -> CGPoint  {
        UIGraphicsPushContext(context)
        CGContextBeginPath(context)
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let thumbOrigin = CircularSliderHelper.endPoint(fromCircle: circle, angle: angle)
        let imageSize = image.size
        let imageFrame = CGRectMake(thumbOrigin.x - (imageSize.width / 2), thumbOrigin.y - (imageSize.height / 2), imageSize.width, imageSize.height)
        image.drawInRect(imageFrame)
        UIGraphicsPopContext()
        
        return thumbOrigin
    }
}
