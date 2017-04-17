//
//  CircularSlider+Math.swift
//  Pods
//
//  Created by Hamza Ghazouani on 21/10/2016.
//
//

import UIKit

// MARK: - Internal Structures
internal struct Interval {
    var min: CGFloat = 0.0
    var max: CGFloat = 0.0
    var rounds: Int

    init(min: CGFloat, max: CGFloat, rounds: Int = 1) {
        assert(min <= max && rounds > 0, NSLocalizedString("Illegal interval", comment: ""))
        
        self.min = min
        self.max = max
        self.rounds = rounds
    }
}

internal struct Circle {
    var origin = CGPoint.zero
    var radius: CGFloat = 0
    
    init(origin: CGPoint, radius: CGFloat) {
        assert(radius >= 0, NSLocalizedString("Illegal radius value", comment: ""))
        
        self.origin = origin
        self.radius = radius
    }
}

internal struct Arc {
    
    var circle = Circle(origin: CGPoint.zero, radius: 0)
    var startAngle: CGFloat = 0.0
    var endAngle: CGFloat = 0.0
    
    init(circle: Circle, startAngle: CGFloat, endAngle: CGFloat) {
    
        self.circle = circle
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
}

// MARK: - Internal Extensions
internal extension CGVector {
    
    /**
     Calculate the vector between two points
     
     - parameter source:      the source point
     - parameter end:       the destination point
     
     - returns: returns the vector between source and the end point
     */
    init(sourcePoint source: CGPoint, endPoint end: CGPoint) {
        let dx = end.x - source.x
        let dy = end.y - source.y
        self.init(dx: dx, dy: dy)
    }
    
    func dotProduct(_ v: CGVector) -> CGFloat {
        let dotProduct = (dx * v.dx) + (dy * v.dy)
        return dotProduct
    }
    
    func determinant(_ v: CGVector) -> CGFloat {
        let determinant = (v.dx * dy) - (dx * v.dy)
        return determinant
    }
    
    static func dotProductAndDeterminant(fromSourcePoint source: CGPoint, firstPoint first: CGPoint, secondPoint second: CGPoint) -> (dotProduct: Float, determinant: Float) {
        let u = CGVector(sourcePoint: source, endPoint: first)
        let v = CGVector(sourcePoint: source, endPoint: second)
        
        let dotProduct = u.dotProduct(v)
        let determinant = u.determinant(v)
        return (Float(dotProduct), Float(determinant))
    }
}

internal extension CGRect {
 
    // get the center of rect (bounds or frame)
    internal var center: CGPoint {
        get {
            let center = CGPoint(x: midX, y: midY)
            return center
        }
    }
}

// MARK: - Internal Helper
internal class CircularSliderHelper {
    
    @nonobjc static let circleMinValue: CGFloat = 0
    @nonobjc static let circleMaxValue: CGFloat = CGFloat(2 * Double.pi)
    @nonobjc static let circleInitialAngle: CGFloat = -CGFloat(Double.pi / 2)
    
    /**
     Convert angle from radians to degrees
     
     - parameter value: radians value
     
     - returns: degree value
     */
    internal static func degrees(fromRadians value: CGFloat) -> CGFloat {
        return value * 180.0 / CGFloat(Double.pi)
    }

    /**
     Returns the angle AÔB of an circle
     
     - parameter firstPoint:  the first point
     - parameter secondPoint: the second point
     - parameter center:      the center of the circle
     
     - returns: Returns the angle AÔB of an circle
     */
    internal static func angle(betweenFirstPoint firstPoint: CGPoint, secondPoint: CGPoint, inCircleWithCenter center: CGPoint) -> CGFloat {
        /*
         we get the angle by using two vectors
         http://www.vitutor.com/geometry/vec/angle_vectors.html
         https://www.mathsisfun.com/geometry/unit-circle.html
         https://en.wikipedia.org/wiki/Dot_product
         https://en.wikipedia.org/wiki/Determinant
         */
        
        let uv = CGVector.dotProductAndDeterminant(fromSourcePoint: center, firstPoint: firstPoint, secondPoint: secondPoint)
        let angle = atan2(uv.determinant, uv.dotProduct)
        
        // change the angle interval
        let newAngle = (angle < 0) ? -angle : Float(Double.pi * 2) - angle
        
        return CGFloat(newAngle)
    }
    
    /**
     Given a specific angle, returns the coordinates of the end point in the circle
     
     - parameter circle: the circle
     - parameter angle:  the angle value
     
     - returns: the coordinates of the end point
     */
    internal static func endPoint(fromCircle circle: Circle, angle: CGFloat) -> CGPoint {
        /*
         to get coordinate from angle of circle
         https://www.mathsisfun.com/polar-cartesian-coordinates.html
         */
        
        let x = circle.radius * cos(angle) + circle.origin.x // cos(α) = x / radius
        let y = circle.radius * sin(angle) + circle.origin.y // sin(α) = y / radius
        let point = CGPoint(x: x, y: y)
        
        return point
    }
    
    /**
     Scale the value from an interval to another
     
     For example if the value is 0.5 and the interval is [0, 1]
     the new value is equal to 4 in the new interval [0, 8]
     
     - parameter value:       the value
     - parameter source:      the old interval
     - parameter destination: the new interval
     
     - returns: the value in the new interval
     */
    internal static func scaleValue(_ value: CGFloat, fromInterval source: Interval, toInterval destination: Interval) -> CGFloat {
        let sourceRange = (source.max - source.min) / CGFloat(source.rounds)
        let destinationRange = (destination.max - destination.min) / CGFloat(destination.rounds)
        let scaledValue = source.min + (value - source.min).truncatingRemainder(dividingBy: sourceRange)
        let newValue =  (((scaledValue - source.min) * destinationRange) / sourceRange) + destination.min
        
        return  newValue
    }
    
    /**
     Scale the value from the initial interval to circle interval
     The angle interval  is [0, 2π]
     
     For example if the value is 0.5 and the interval is [0, 1]
     the angle value is equal to π
     
     @see value(inInterval: fromAngle:)

     - parameter aValue:      the original value
     - parameter oldIntreval: the original interval
     
     - returns: the angle value
     */
    internal static func scaleToAngle(value aValue: CGFloat, inInterval oldInterval: Interval) -> CGFloat {
        let angleInterval = Interval(min: circleMinValue , max: circleMaxValue)
        
        let angle = scaleValue(aValue, fromInterval: oldInterval, toInterval: angleInterval)
        return  angle
    }
    
    /**
     Scale the value from the circle interval to the new interval
     The angle interval is [0, 2π]
     
     For example if the value is π and the interval is [0, 2π]
     the new value is equal to 1 in the interval [0, 2]
     
     - parameter newInterval: the new interval
     - parameter angle:       the angle value
     
     - returns: the value in the new interval 
     */
    internal static func value(inInterval newInterval: Interval, fromAngle angle: CGFloat) -> CGFloat {
        let angleIntreval = Interval(min: circleMinValue , max: circleMaxValue)
        let value = scaleValue(angle, fromInterval: angleIntreval, toInterval: newInterval)
        
        return value
    }

    internal static func delta(in interval: Interval, for angle: CGFloat, oldValue: CGFloat) -> CGFloat {
        let angleIntreval = Interval(min: circleMinValue , max: circleMaxValue)

        let oldAngle = scaleToAngle(value: oldValue, inInterval: interval)
        let deltaAngle = self.angle(from: oldAngle, to: angle)

        return scaleValue(deltaAngle, fromInterval: angleIntreval, toInterval: interval)
    }

    /**
     * Length (angular) of a shortest way between two angles.
     * It will be in range [-π/2, π/2], where sign means dir (+ for clockwise, - for counter clockwise).
     */
    private static  func angle(from alpha: CGFloat, to beta: CGFloat) -> CGFloat {
        let halfValue = circleMaxValue/2
        // Rotate right
        let offset = alpha >= halfValue ? circleMaxValue - alpha : -alpha
        let offsetBeta = beta + offset

        if offsetBeta > halfValue {
            return offsetBeta - circleMaxValue
        }
        else {
            return offsetBeta
        }
    }
}
