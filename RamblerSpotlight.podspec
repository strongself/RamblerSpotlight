#
# Be sure to run `pod lib lint RamblerSpotlight.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RamblerSpotlight'
  s.version          = '0.1.0'
  s.summary          = 'A short description of RamblerSpotlight.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/RamblerSpotlight'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'k.zinovyev' => 'k.zinovyev@rambler-co.ru' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/RamblerSpotlight.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'RamblerSpotlight/Classes/**/*{h,m}'
  s.frameworks = 'CoreData'
  s.resource_bundles = {
    'RamblerSpotlightDataBase' => ['RamblerSpotlight/Classes/CoreDataStack/DataModel/*.xcdatamodeld']
   }

end
