#
# Be sure to run `pod lib lint tuva-core.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TuvaCore'
  s.version          = '0.0.14'
  s.summary          = 'Common Extensions on system types'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Common Extensions on system types, tested and usefull
                       DESC

  s.homepage         = 'https://github.com/fuzz-productions/tuva-core-iosmodule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nick Trienens' => 'nick@fuzz.pro' }
  s.source           = { :git => 'git@github.com:fuzz-productions/tuva-core-iosmodule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.15'
  #s.tvos.deployment_target = '10.0'
  s.swift_version = '5.3'
  
  
  s.default_subspecs = "All"

  s.subspec 'Core' do |core|
      core.source_files = [ 'Sources/TuvaCore/Classes/*.swift',
          'Sources/TuvaCore/Classes/Protocols/*.swift']

  end

  s.subspec 'UIKit' do |uiKit|
    uiKit.dependency 'TuvaCore/Core'
    uiKit.source_files = [ 'Sources/TuvaCore/Classes/UIKit/*.swift']
  end

  s.subspec 'Foundation' do |foundation|
    foundation.dependency 'TuvaCore/Core'
    foundation.source_files = [ 'Sources/TuvaCore/Classes/Foundation/*.swift']
  end

  s.subspec 'Image' do |image|
    image.dependency 'TuvaCore/Core'
    image.dependency 'TuvaCore/UIKit'
    image.dependency 'TuvaCore/Foundation'
    image.source_files = [ 'Sources/TuvaCore/Classes/Image/*.swift']
  end

  s.subspec 'All' do |all|
    all.dependency 'TuvaCore/Core'
    all.dependency 'TuvaCore/UIKit'
    all.dependency 'TuvaCore/Image'
    all.dependency 'TuvaCore/Foundation'
  end

end
