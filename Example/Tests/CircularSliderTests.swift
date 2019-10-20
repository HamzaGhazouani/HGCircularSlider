//
//  CircularSliderTests.swift
//  HGCircularSlider_Tests
//
//  Created by Hamza on 20/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import HGCircularSlider

class CircularSliderTests: XCTestCase {
    
    func testEndPointPositionWithZeroAsInitialValueAnd90DegreesAsTouchPosition() {
        // Given
        let circularSlider = CircularSlider(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let startPosition = CGPoint(x: 25, y: 0)
        circularSlider.minimumValue = 0
        circularSlider.maximumValue = 100
        circularSlider.endPointValue = 0
        
        let touchPosition = CGPoint(x: 50, y: 25)
        
        // When
        let newValue = circularSlider.newValue(from: circularSlider.endPointValue, touch: touchPosition, start: startPosition)
        
        // Then
        XCTAssertEqual(newValue, 25, accuracy: 0.001)
    }
    
    func testEndPointPositionWithValueGratherThanZeroAsInitialValueAnd90DegreesAsTouchPosition() {
        // Given
        let circularSlider = CircularSlider(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let startPosition = CGPoint(x: 25, y: 0)
        circularSlider.minimumValue = 5
        circularSlider.maximumValue = 25
        circularSlider.endPointValue = 5
        
        let touchPosition = CGPoint(x: 50, y: 25)
        
        // When
        let newValue = circularSlider.newValue(from: circularSlider.endPointValue, touch: touchPosition, start: startPosition)
        
        // Then
        XCTAssertEqual(newValue, 10, accuracy: 0.001)
    }
    
    func testndPointPositionWithValueGratherThanZeroAsInitialValueAnd180DegreesAsTouchPosition() {
        // Given
        let circularSlider = CircularSlider(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let startPosition = CGPoint(x: 25, y: 0)
        circularSlider.minimumValue = 5
        circularSlider.maximumValue = 25
        circularSlider.endPointValue = 10
        
        let touchPosition = CGPoint(x: 25, y: 50)
        
        // When
        let newValue = circularSlider.newValue(from: circularSlider.endPointValue, touch: touchPosition, start: startPosition)
        
        // Then
        XCTAssertEqual(newValue, 15, accuracy: 0.001)
    }
    
    func testndPointPositionWithValueGratherThanZeroAsInitialValueAnd270DegreesAsTouchPosition() {
        // Given
        let circularSlider = CircularSlider(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let startPosition = CGPoint(x: 25, y: 0)
        circularSlider.minimumValue = 5
        circularSlider.maximumValue = 25
        circularSlider.endPointValue = 10
        
        let touchPosition = CGPoint(x: 0, y: 25)
        
        // When
        let newValue = circularSlider.newValue(from: circularSlider.endPointValue, touch: touchPosition, start: startPosition)
        
        // Then
        XCTAssertEqual(newValue, 20, accuracy: 0.001)
    }
    
    func testndPointPositionWithValueGratherThanZeroAsInitialValueAnd360DegreesAsTouchPosition() {
        // Given
        let circularSlider = CircularSlider(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let startPosition = CGPoint(x: 25, y: 0)
        circularSlider.minimumValue = 5
        circularSlider.maximumValue = 25
        circularSlider.endPointValue = 10
        
        let touchPosition = CGPoint(x: 24.999, y: 0)
        
        // When
        let newValue = circularSlider.newValue(from: circularSlider.endPointValue, touch: touchPosition, start: startPosition)
        
        // Then
        XCTAssertEqual(newValue, 25, accuracy: 0.001)
    }
}
