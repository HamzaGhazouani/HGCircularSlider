#
# Be sure to run `pod lib lint HGCircularSlider.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name               = 'HGCircularSlider'
s.version            = '2.2.0'
s.summary            = 'Multiple Circular Sliders used to select a value from a continuous range of values.'
s.swift_version      = '5.0'

s.description      = <<-DESC
Circular Sliders used to select a value from a continuous range of values.

CircularSlider: simple circular slider
RangeCircularSlider: slider with two points to select a range of values from a continuous range of values
MidPointCircularSlider: slider with fixed range to select a range of values from a continuois range of values

DESC

s.homepage         = 'https://github.com/HamzaGhazouani/HGCircularSlider'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Hamza Ghazouani' => 'hamza.ghazouani@gmail.com' }
s.source           = { :git => 'https://github.com/HamzaGhazouani/HGCircularSlider.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/GhazouaniHamza'

s.ios.deployment_target = '8.0'

s.source_files = 'HGCircularSlider/Classes/**/*'

end
