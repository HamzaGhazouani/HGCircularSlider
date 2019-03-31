# HGCircularSlider

[![Twitter: @GhazouaniHamza](https://img.shields.io/badge/contact-@GhazouaniHamza-blue.svg?style=flat)](https://twitter.com/GhazouaniHamza)
[![CI Status](http://img.shields.io/travis/HamzaGhazouani/HGCircularSlider.svg?style=flat)](https://travis-ci.org/HamzaGhazouani/HGCircularSlider)
[![Version](https://img.shields.io/cocoapods/v/HGCircularSlider.svg?style=flat)](http://cocoapods.org/pods/HGCircularSlider)
[![License](https://img.shields.io/cocoapods/l/HGCircularSlider.svg?style=flat)](http://cocoapods.org/pods/HGCircularSlider)
[![Language](https://img.shields.io/badge/language-Swift-orange.svg?style=flat)]()
[![Platform](https://img.shields.io/cocoapods/p/HGCircularSlider.svg?style=flat)](http://cocoapods.org/pods/HGCircularSlider)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<br />

[![codebeat badge](https://codebeat.co/badges/c4db03f5-903a-4b0e-84bb-98362fc5bd7a)](https://codebeat.co/projects/github-com-hamzaghazouani-hgcircularslider)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/HGCircularSlider.svg)](http://cocoadocs.org/docsets/HGCircularSlider/)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/hamzaghazouani/hgcircularslider/)](http://clayallsopp.github.io/readme-score?url=https://github.com/hamzaghazouani/hgcircularslider/tree/develop)

## Example

![](/Screenshots/Bedtime.gif) ![](/Screenshots/Player.gif) ![](/Screenshots/OClock.gif) ![](/Screenshots/Other.gif) ![](/Screenshots/Circular.gif)

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 9.0+
- Xcode 8.0

## Installation

HGCircularSlider is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

``` ruby
# Swift 3.1 - Xcode 8.3
pod 'HGCircularSlider', '~> 2.0.0'

# Swift 3 - Xcode 8
pod 'HGCircularSlider', '~> 1.0.3'

# Swift 2.2 - Xcode 7.3.1 (Checkout Swift2_Xcode7.3 branche)
pod 'HGCircularSlider', '~> 0.1.2'
```

HGCircularSlider is also available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:


``` ruby
# Swift 3.1 - Xcode 8
github "HamzaGhazouani/HGCircularSlider"
```

## Usage

1. Change the class of a view from UIView to CircularSlider, RangeCircularSlider or MidPointCircularSlider
2. Programmatically:

```
let circularSlider = CircularSlider(frame: myFrame)
circularSlider.minimumValue = 0.0
circularSlider.maximumValue = 1.0
circularSlider.endPointValue = 0.2

```
OR
```
let circularSlider = RangeCircularSlider(frame: myFrame)
circularSlider.startThumbImage = UIImage(named: "Bedtime")
circularSlider.endThumbImage = UIImage(named: "Wake")

let dayInSeconds = 24 * 60 * 60
circularSlider.maximumValue = CGFloat(dayInSeconds)

circularSlider.startPointValue = 1 * 60 * 60
circularSlider.endPointValue = 8 * 60 * 60
circularSlider.numberOfRounds = 2 // Two rotations for full 24h range
```
OR
```
let circularSlider = MidPointCircularSlider(frame: myFrame)
circularSlider.minimumValue = 0.0
circularSlider.maximumValue = 10.0
circularSlider.distance = 1.0
circularSlider.midPointValue = 5.0
```
## Documentation
Full documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/HGCircularSlider/).<br/>
You can also install documentation locally using [jazzy](https://github.com/realm/jazzy).

## References
The UI examples of the demo project inspired from [Dribbble](https://dribbble.com).

[Player](https://dribbble.com/shots/3062636-Countdown-Timer-Daily-UI-014) <br/>
[BasicExample](https://dribbble.com/shots/2153963-Dompet-Wallet-App)<br/>
[OClock](https://dribbble.com/shots/2671286-Clock-Alarm-app)<br/>

The project is Inspired by [UICircularSlider](https://github.com/Zedenem/UICircularSlider)

## Author

Hamza Ghazouani, hamza.ghazouani@gmail.com

## License

HGCircularSlider is available under the MIT license. See the LICENSE file for more info.
