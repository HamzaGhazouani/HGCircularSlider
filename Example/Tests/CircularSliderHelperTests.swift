//
//  CircularSliderHelperTests.swift
//  HGCircularSlider_Tests
//
//  Created by Hamza GHAZOUANI on 24/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import HGCircularSlider

extension CGFloat {
    
    var toDegrees: CGFloat {
        return self * 180.0 / CGFloat(Double.pi)
    }
}

class CircularSliderHelperTests: XCTestCase {
    
    let cirlceInterval = Interval(min: 0 , max: CGFloat(2 * Double.pi))
    let valuesInterval = Interval(min: 0, max: 1.2)

    func testInitialValueScale() {
        // Given
        let value = valuesInterval.min
        
        // Thene
        let angle  = CircularSliderHelper.scaleValue(value, fromInterval: valuesInterval, toInterval: cirlceInterval).toDegrees
        XCTAssertEqual(angle, 0)
    }
    
    func testFinalValueScale() {
        // Given
        let value: CGFloat = valuesInterval.max
        
        // Thene
        let angle  = CircularSliderHelper.scaleValue(value, fromInterval: valuesInterval, toInterval: cirlceInterval).toDegrees
        XCTAssertEqual(angle, 360)
    }
    
    func testMedianValueScale() {
        // Given
        let value: CGFloat = valuesInterval.max / 2
        
        // Thene
        let angle  = CircularSliderHelper.scaleValue(value, fromInterval: valuesInterval, toInterval: cirlceInterval).toDegrees
        XCTAssertEqual(angle, 180)
    }
}
