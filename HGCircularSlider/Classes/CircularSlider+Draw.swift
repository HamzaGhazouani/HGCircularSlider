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
     * Draw arc that will have it's stroke path filled with a linear or radial gradient.
     *
     *
     - parameter arc:           the arc coordinates (origin, radius, start angle, end angle)
     - parameter lineWidth:     the with of the circle line (optional) by default 2px
     - parameter context:       the context
     */
    internal static func drawGradientArc(withArc arc: Arc,
                                         colors: [CGColor],
                                         locations: [CGFloat],
                                         frame: CGRect,
                                         lineWidth: CGFloat = 2,
                                         cachedGradientImage: inout CGImage?,
                                         inContext context: CGContext) {
        
        if cachedGradientImage == nil {
            cachedGradientImage = gradientImage(
                type: .conical,
                size: frame.size,
                colors: colors,
                locations: locations.map { Float($0) },
                scale: 0.25)
            
            cachedGradientImage = createMatchingBackingDataWithImage(imageRef: cachedGradientImage, customRotation: 92.0, customMirrored: true, customSwapWidthHeight: true)
            
        }
        
        let circle = arc.circle
        let origin = circle.origin
                
        UIGraphicsPushContext(context)
        context.saveGState()
        context.beginPath()
        
        context.setLineWidth(lineWidth)
        context.setLineCap(CGLineCap.round)
        context.addArc(center: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        context.move(to: CGPoint(x: origin.x, y: origin.y))

        context.replacePathWithStrokedPath()
        context.clip()
        
        // Cache this later
        if let image = cachedGradientImage {
            context.draw(image, in: CGRect(origin: .zero, size: frame.size))
        }
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
    /**
     Draw arc with stroke mode (Stroke) or Disk (Fill) or both (FillStroke) mode
     FillStroke used by default
     
     - parameter arc:           the arc coordinates (origin, radius, start angle, end angle)
     - parameter lineWidth:     the with of the circle line (optional) by default 2px
     - parameter mode:          the mode of the path drawing (optional) by default FillStroke
     - parameter context:       the context
     
     */
    internal static func drawArc(withArc arc: Arc, lineWidth: CGFloat = 2, mode: CGPathDrawingMode = .fillStroke, inContext context: CGContext, withShadow shadowed: Bool = false) {
        
        let circle = arc.circle
        let origin = circle.origin
        
        UIGraphicsPushContext(context)
        context.beginPath()
        
        context.setLineWidth(lineWidth)
        context.setLineCap(CGLineCap.round)
        context.addArc(center: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        context.move(to: CGPoint(x: origin.x, y: origin.y))
        
        if shadowed {
            context.setShadow(offset: .zero, blur: circle.radius, color: UIColor.black.cgColor)
        }
        
        context.drawPath(using: mode)

        UIGraphicsPopContext()
    }
    
    /**
     Draw disk using arc coordinates
     
     - parameter arc:     the arc coordinates (origin, radius, start angle, end angle)
     - parameter context: the context
     */
    internal static func drawDisk(withArc arc: Arc, inContext context: CGContext) {

        let circle = arc.circle
        let origin = circle.origin

        UIGraphicsPushContext(context)
        
        context.beginPath()
        
        context.setLineWidth(0)
        context.addArc(center: origin, radius: circle.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, clockwise: false)
        context.addLine(to: CGPoint(x: origin.x, y: origin.y))
        context.drawPath(using: .fill)
        
        UIGraphicsPopContext()
    }

    // MARK: drawing instance methods

    /// Draw the circular slider
    internal func drawCircularSlider(inContext context: CGContext) {
        diskColor.setFill()
        trackColor.setStroke()

        let circle = Circle(origin: bounds.center, radius: self.radius)
        let sliderArc = Arc(circle: circle, startAngle: CircularSliderHelper.circleMinValue, endAngle: CircularSliderHelper.circleMaxValue)
        
        CircularSlider.drawArc(
            withArc: sliderArc,
            lineWidth: backtrackLineWidth,
            inContext: context)
    }

    /// draw Filled arc between start an end angles
    internal func drawFilledArc(fromAngle startAngle: CGFloat, toAngle endAngle: CGFloat, inContext context: CGContext) {
        diskFillColor.setFill()
        trackFillColor.setStroke()
        
        let circle = Circle(origin: bounds.center, radius: self.radius)
        let arc = Arc(circle: circle, startAngle: startAngle, endAngle: endAngle)
        
        // fill Arc
        CircularSlider.drawDisk(withArc: arc, inContext: context)
        
        // stroke Arc
        if trackFillColors.count > 0 {
            CircularSlider.drawGradientArc(
                withArc: arc,
                colors: trackFillColors.map { $0.cgColor },
                locations: trackFillColorLocations,
                frame: frame,
                lineWidth: lineWidth,
                cachedGradientImage: &cachedGradientImage,
                inContext: context)
        } else {
            CircularSlider.drawArc(withArc: arc, lineWidth: lineWidth, mode: .stroke, inContext: context)
        }
    }

    internal func drawShadowArc(fromAngle startAngle: CGFloat, toAngle endAngle: CGFloat, inContext context: CGContext) {
        trackShadowColor.setStroke()

        let origin = CGPoint(x: bounds.center.x + trackShadowOffset.x, y: bounds.center.y + trackShadowOffset.y)
        let circle = Circle(origin: origin, radius: self.radius)
        let arc = Arc(circle: circle, startAngle: startAngle, endAngle: endAngle)

        // stroke Arc
        CircularSlider.drawArc(withArc: arc, lineWidth: lineWidth, mode: .stroke, inContext: context)
    }

    /**
     Draw the thumb and return the coordinates of its center
     
     - parameter angle:   the angle of the point in the main circle
     - parameter image:   the image of the thumb, if it's nil we use a disk (circle), the default value is nil
     - parameter context: the context
     
     - returns: return the origin point of the thumb
     */
    @discardableResult
    internal func drawThumbAt(_ angle: CGFloat, with image: UIImage? = nil, inContext context: CGContext) -> CGPoint {
        let circle = Circle(origin: bounds.center, radius: self.radius + self.thumbOffset)
        let thumbOrigin = CircularSliderHelper.endPoint(fromCircle: circle, angle: angle)
        
        if let image = image {
            return drawThumb(withImage: image, thumbOrigin: thumbOrigin, inContext: context)
        }
        
        // Draw a disk as thumb
        let thumbCircle = Circle(origin: thumbOrigin, radius: thumbRadius)
        let thumbArc = Arc(circle: thumbCircle, startAngle: CircularSliderHelper.circleMinValue, endAngle: CircularSliderHelper.circleMaxValue)

        CircularSlider.drawArc(withArc: thumbArc, lineWidth: thumbLineWidth, inContext: context, withShadow: thumbShadow)
                
        return thumbOrigin
    }

    /**
     Draw thumb using image and return the coordinates of its center

     - parameter image:   the image of the thumb
     - parameter angle:   the angle of the point in the main circle
     - parameter context: the context
     
     - returns: return the origin point of the thumb
     */
    @discardableResult
    private func drawThumb(withImage image: UIImage, thumbOrigin: CGPoint, inContext context: CGContext) -> CGPoint {
        UIGraphicsPushContext(context)
        context.beginPath()
        let imageSize = image.size
        let imageFrame = CGRect(x: thumbOrigin.x - (imageSize.width / 2), y: thumbOrigin.y - (imageSize.height / 2), width: imageSize.width, height: imageSize.height)
        image.draw(in: imageFrame)
        UIGraphicsPopContext()

        return thumbOrigin
    }
}
