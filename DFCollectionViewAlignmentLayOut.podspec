#
# Be sure to run `pod lib lint DFCollectionViewAlignmentLayOut.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DFCollectionViewAlignmentLayOut'
  s.version          = '0.2.0'
  s.summary          = '带对齐方式的UICollectionView布局'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
UICollectionViewLayOut with 3 alignments (include left, right and middle).
更新说明：
增加流水布局样式，要求section必须为1，且只能垂直滑动，不支持header/footer；补充说明文档；
                       DESC

  s.homepage         = 'https://github.com/quanchengk/DFCollectionViewAlignmentLayOut'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danfort' => 'quanchengk@163.com' }
  s.source           = { :git => 'https://github.com/quanchengk/DFCollectionViewAlignmentLayOut.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DFCollectionViewAlignmentLayOut/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DFCollectionViewAlignmentLayOut' => ['DFCollectionViewAlignmentLayOut/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
