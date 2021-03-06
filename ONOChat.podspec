#
# Be sure to run `pod lib lint ONOChat.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ONOChat'
  s.version          = '0.1.1'
  s.summary          = 'ONOChat.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
IM SDK for ONO chat.
                       DESC

  s.homepage         = 'https://github.com/lhs168/ONOChat'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kevin' => 'lhs168@gmail.com' }
  s.source           = { :git => 'https://github.com/lhs168/ONOChat.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'ONOChat/Classes/**/*'
  non_arc_files = 'ONOChat/Classes/proto/*'
  s.exclude_files = non_arc_files
  s.subspec 'ONOProto' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end
  # s.resource_bundles = {
  #   'ONOChat' => ['ONOChat/Assets/*.png']
  # }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Protobuf', '~> 3.5.0'
  s.dependency 'FMDB', '~> 2.7.2'

  # Set a CPP symbol so the code knows to use framework imports.
  s.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1' }
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1' }
end
