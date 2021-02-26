//
//  CircularSlider+GradientGenerator.swift
//  HGCircularSlider
//
//  Created by Piotr Suwara on 21/2/20.
//  Adapted from the MKGradientView by https://github.com/maxkonovalov

import UIKit

// MARK: - Utility
private func lerp(_ t: Float, _ a: UInt8, _ b: UInt8) -> UInt8 {
    return UInt8(Float(a) + min(max(t, 0), 1) * (Float(b) - Float(a)))
}

private func lerp(_ value: Float, inRange: ClosedRange<Float>, outRange: ClosedRange<Float>) -> Float {
    return (value - inRange.lowerBound) * (outRange.upperBound - outRange.lowerBound) / (inRange.upperBound - inRange.lowerBound) + outRange.lowerBound
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return (indices ~= index) ? self[index] : nil
    }
}

// MARK: - Color Data
fileprivate struct RGBA: Equatable {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}

fileprivate extension RGBA {
    
    init() {
        self.init(r: 0, g: 0, b: 0, a: 0)
    }
    
    init(_ hex: Int) {
        let r = UInt8((hex >> 16) & 0xff)
        let g = UInt8((hex >> 08) & 0xff)
        let b = UInt8((hex >> 00) & 0xff)
        self.init(r: r, g: g, b: b, a: 0xff)
    }
    
    init(_ color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(r: UInt8(r * 0xff), g: UInt8(g * 0xff), b: UInt8(b * 0xff), a: UInt8(a * 0xff))
    }
    
    init(_ color: CGColor) {
        let c = color.components?.map { min(max($0, 0.0), 1.0) } ?? []
        switch c.count {
        case 2:
            self.init(r: UInt8(c[0] * 0xff), g: UInt8(c[0] * 0xff), b: UInt8(c[0] * 0xff), a: UInt8(c[1] * 0xff))
        case 4:
            self.init(r: UInt8(c[0] * 0xff), g: UInt8(c[1] * 0xff), b: UInt8(c[2] * 0xff), a: UInt8(c[3] * 0xff))
        default:
            self.init()
        }
    }
    
    var uiColor: UIColor {
        return UIColor(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: CGFloat(a) / 0xff)
    }
    
    var cgColor: CGColor {
        return uiColor.cgColor
    }
    
    func interpolate(to color: RGBA, _ t: Float) -> RGBA {
        let r = lerp(t, self.r, color.r)
        let g = lerp(t, self.g, color.g)
        let b = lerp(t, self.b, color.b)
        let a = lerp(t, self.a, color.a)
        return RGBA(r: r, g: g, b: b, a: a)
    }
}

extension CircularSlider {
    
    public enum GradientType: Int {
        case linear
        case radial
        case conical
        case bilinear
    }
    
    internal static func createMatchingBackingDataWithImage(
        imageRef: CGImage?,
        orienation: UIImage.Orientation = .down,
        customRotation: Double? = nil,
        customMirrored: Bool = false,
        customSwapWidthHeight: Bool = false) -> CGImage? {
        var orientedImage: CGImage?

        guard let imageRef = imageRef else { return nil }
        
        let originalWidth = imageRef.width
        let originalHeight = imageRef.height
        let bitsPerComponent = imageRef.bitsPerComponent
        let bytesPerRow = imageRef.bytesPerRow

        let colorSpace = imageRef.colorSpace
        let bitmapInfo = imageRef.bitmapInfo

        var degreesToRotate: Double
        var swapWidthHeight: Bool
        var mirrored: Bool
        
        if let degrees = customRotation {
            degreesToRotate = degrees
            swapWidthHeight = customSwapWidthHeight
            mirrored = customMirrored
        } else {
            switch orienation {
            case .up:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = false
                break
            case .upMirrored:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = true
                break
            case .right:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .rightMirrored:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = true
                break
            case .down:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = false
                break
            case .downMirrored:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = true
                break
            case .left:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .leftMirrored:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = true
                break
            @unknown default:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = false
                break
            }
        }
        
        let radians = degreesToRotate * Double.pi / 180

        var width: Int
        var height: Int
        if swapWidthHeight {
            width = originalHeight
            height = originalWidth
        } else {
            width = originalWidth
            height = originalHeight
        }

        if let contextRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue) {

            contextRef.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
            if mirrored {
                contextRef.scaleBy(x: -1.0, y: 1.0)
            }
            contextRef.rotate(by: CGFloat(radians))
            if swapWidthHeight {
                contextRef.translateBy(x: -CGFloat(height) / 2.0, y: -CGFloat(width) / 2.0)
            } else {
                contextRef.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
            }
            contextRef.draw(imageRef, in: CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight))

            orientedImage = contextRef.makeImage()
        }

        return orientedImage
    }
    
    internal static func gradientImage(
        type: GradientType,
        size: CGSize,
        colors: [CGColor],
        colors2: [CGColor]? = nil,
        locations: [Float]? = nil,
        locations2: [Float]? = nil,
        startPoint: CGPoint? = nil,
        endPoint: CGPoint? = nil,
        startPoint2: CGPoint? = nil,
        endPoint2: CGPoint? = nil,
        scale: CGFloat? = nil) -> CGImage? {
        
        let w = Int(size.width * (scale ?? UIScreen.main.scale))
        let h = Int(size.height * (scale ?? UIScreen.main.scale))
        let bitsPerComponent: Int = MemoryLayout<UInt8>.size * 8
        let bytesPerPixel: Int = bitsPerComponent * 4 / 8
        let colorSpace: CGColorSpace
        
        if #available(iOS 12.0, *) {
            colorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB()
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var data = [RGBA]()
        
        for y in 0..<h {
            for x in 0..<w {
                let c = pixelDataForGradient(type, colors: [colors, colors2], locations: [locations, locations2], startPoints: [startPoint, startPoint2], endPoints: [endPoint, endPoint2], point: CGPoint(x: x, y: y), size: CGSize(width: w, height: h))
                data.append(c)
            }
        }
        
        let image: CGImage? = withExtendedLifetime(&data) { (data: UnsafeMutableRawPointer) -> CGImage? in
                     guard let ctx = CGContext(
                         data: data,
                         width: w,
                         height: h,
                         bitsPerComponent: bitsPerComponent,
                         bytesPerRow: w * bytesPerPixel,
                         space: colorSpace,
                         bitmapInfo: bitmapInfo.rawValue
                     ) else {
                         return nil
                     }

                      return ctx.makeImage()
                 }

        return image
    }
        
    private static func pixelDataForGradient(
        _ gradientType: GradientType,
        colors: [[CGColor]?],
        locations: [[Float]?],
        startPoints: [CGPoint?],
        endPoints: [CGPoint?],
        point: CGPoint,
        size: CGSize) -> RGBA {
        
        assert(colors.count > 0)
            
        var colors = colors
        var locations = locations
        var startPoints = startPoints
        var endPoints = endPoints
        
        if gradientType == .bilinear && colors.count == 1 {
            colors.append([UIColor.clear.cgColor])
        }
        
        for (index, colorArray) in colors.enumerated() {
            if gradientType != .bilinear && index > 0 {
                continue
            }
            if colorArray == nil {
                colors[index] = [UIColor.clear.cgColor]
            }
            if locations.count <= index {
                locations.append(uniformLocationsWithCount(colorArray!.count))
            } else if locations[index] == nil {
                locations[index] = uniformLocationsWithCount(colorArray!.count)
            }
            if startPoints.count <= index {
                startPoints.append(nil)
            }
            if endPoints.count <= index {
                endPoints.append(nil)
            }
        }
        
        switch gradientType {
        case .linear:
            let g0 = startPoints[0] ?? CGPoint(x: 0.5, y: 0.0)
            let g1 = endPoints[0] ?? CGPoint(x: 0.5, y: 1.0)
            let t = linearGradientStop(point, size, g0, g1)
            return interpolatedColor(t, colors[0]!, locations[0]!)
        case .radial:
            let g0 = startPoints[0] ?? CGPoint(x: 0.5, y: 0.5)
            let g1 = endPoints[0] ?? CGPoint(x: 1.0, y: 0.5)
            let t = radialGradientStop(point, size, g0, g1)
            return interpolatedColor(t, colors[0]!, locations[0]!)
        case .conical:
            let g0 = startPoints[0] ?? CGPoint(x: 0.5, y: 0.5)
            let g1 = endPoints[0] ?? CGPoint(x: 1.0, y: 0.5)
            let t = conicalGradientStop(point, size, g0, g1)
            return interpolatedColor(t, colors[0]!, locations[0]!)
        case .bilinear:
            let g0x = startPoints[0] ?? CGPoint(x: 0.0, y: 0.5)
            let g1x = endPoints[0] ?? CGPoint(x: 1.0, y: 0.5)
            let tx = linearGradientStop(point, size, g0x, g1x)
            let g0y = startPoints[1] ?? CGPoint(x: 0.5, y: 0.0)
            let g1y = endPoints[1] ?? CGPoint(x: 0.5, y: 1.0)
            let ty = linearGradientStop(point, size, g0y, g1y)
            let c1 = interpolatedColor(tx, colors[0]!, locations[0]!)
            let c2 = interpolatedColor(tx, colors[1]!, locations[1]!)
            let c = interpolatedColor(ty, [c1.cgColor, c2.cgColor], [0.0, 1.0])
            return c
        }
    }
        
    private static func uniformLocationsWithCount(_ count: Int) -> [Float] {
        var locations = [Float]()
        for i in 0..<count {
            locations.append(Float(i) / Float(count - 1))
        }
        return locations
    }
    
    private static func linearGradientStop(_ point: CGPoint, _ size: CGSize, _ g0: CGPoint, _ g1: CGPoint) -> Float {
        let s = CGPoint(x: size.width * (g1.x - g0.x), y: size.height * (g1.y - g0.y))
        let p = CGPoint(x: point.x - size.width * g0.x, y: point.y - size.height * g0.y)
        let t = (p.x * s.x + p.y * s.y) / (s.x * s.x + s.y * s.y)
        return Float(t)
    }
    
    private static func radialGradientStop(_ point: CGPoint, _ size: CGSize, _ g0: CGPoint, _ g1: CGPoint) -> Float {
        let c = CGPoint(x: size.width * g0.x, y: size.height * g0.y)
        let s = CGPoint(x: size.width * (g1.x - g0.x), y: size.height * (g1.y - g0.y))
        let d = sqrt(s.x * s.x + s.y * s.y)
        let p = CGPoint(x: point.x - c.x, y: point.y - c.y)
        let r = sqrt(p.x * p.x + p.y * p.y)
        let t = r / d
        return Float(t)
    }
    
    private static func conicalGradientStop(_ point: CGPoint, _ size: CGSize, _ g0: CGPoint, _ g1: CGPoint) -> Float {
        let c = CGPoint(x: size.width * g0.x, y: size.height * g0.y)
        let s = CGPoint(x: size.width * (g1.x - g0.x), y: size.height * (g1.y - g0.y))
        let q = atan2(s.y, s.x)
        let p = CGPoint(x: point.x - c.x, y: point.y - c.y)
        var a = atan2(p.y, p.x) - q
        if a < 0 {
            a += 2 * .pi
        }
        let t = a / (2 * .pi)
        return Float(t)
    }
    
    private static func interpolatedColor(_ t: Float, _ colors: [CGColor], _ locations: [Float]) -> RGBA {
        assert(!colors.isEmpty)
        assert(colors.count == locations.count)
        
        var p0: Float = 0
        var p1: Float = 1
        
        var c0 = colors.first!
        var c1 = colors.last!
        
        for (i, v) in locations.enumerated() {
            if v > p0 && t >= v {
                p0 = v
                c0 = colors[i]
            }
            if v < p1 && t <= v {
                p1 = v
                c1 = colors[i]
            }
        }
        
        let p: Float
        if p0 == p1 {
            p = 0
        } else {
            p = lerp(t, inRange: p0...p1, outRange: 0...1)
        }
        
        let color0 = RGBA(c0)
        let color1 = RGBA(c1)
        
        return color0.interpolate(to: color1, p)
    }
}
