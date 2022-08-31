#
# Be sure to run `pod lib lint FuzzCombine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FuzzCombine'
  s.version          = '0.1.21'
  s.summary          = 'A short description of FuzzCombine.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod contains Combin specific swift helpers to conform to the fuzzproductions style of handling reactive programming in a MVVM setting, as well as a flexible client structure for making network calls.
                       DESC

  s.homepage         = 'https://github.com/fuzz-productions/fuzz-combine-iosmodule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nick Trienens' => 'nick@fuzz.pro' }
  s.source           = { :git => 'git@github.com:fuzz-productions/fuzz-combine-iosmodule.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.macos.deployment_target = '10.15.0'

  #s.source_files = 'FuzzCombine/Classes/*/*'
  s.swift_version = '5.2'

  s.default_subspecs = "All"

  s.subspec 'Core' do |core|
      core.source_files = [ 
          'Sources/FuzzCombine/Classes/Protocols/*.swift',
          'Sources/FuzzCombine/Classes/Extensions/*.swift'
        ]
  end

  s.subspec 'Result' do |uiKit|
    uiKit.dependency 'FuzzCombine/Core'
    uiKit.source_files = [ 'Sources/FuzzCombine/Classes/Result/*.swift']
  end

  s.subspec 'Client' do |foundation|
    foundation.dependency 'FuzzCombine/Core'
    foundation.source_files = [ 'Sources/FuzzCombine/Classes/Client/*.swift']
  end

  s.subspec 'Store' do |image|
    image.dependency 'FuzzCombine/Core'
    image.source_files = [ 'Sources/FuzzCombine/Classes/Store/*.swift']
  end
  s.subspec 'UIBindings' do |image|
    image.dependency 'FuzzCombine/Core'
    image.source_files = [ 'Sources/FuzzCombine/Classes/UIBindings/*.swift']
  end

  s.subspec 'All' do |all|
    all.dependency 'FuzzCombine/Core'
    all.dependency 'FuzzCombine/Result'
    all.dependency 'FuzzCombine/Client'
    all.dependency 'FuzzCombine/Store'
    all.dependency 'FuzzCombine/UIBindings'
  end
  
  s.frameworks = 'Combine'
end
