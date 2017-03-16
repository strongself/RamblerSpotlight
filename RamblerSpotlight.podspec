Pod::Spec.new do |s|
  s.name             = 'RamblerSpotlight'
  s.version          = '1.0.1'
  s.summary          = 'I have Spotlight... I have CoreData... mmm ... RamblerSpotlight'
  s.license          = 'MIT'

  s.homepage         = 'https://gitlab.rambler.ru/cocoapods/RamblerSpotlight'
  s.author           = {
                            'Konstantin Zinovyev' => 'k.zinovyev@rambler-co.ru'
                       }
  s.source           = { :git => 'https://gitlab.rambler.ru/cocoapods/RamblerSpotlight.git', :tag => s.version.to_s }
  s.source_files = 'RamblerSpotlight/Classes/**/*{h,m}'
  s.platform      = :ios, '8.0'
  s.frameworks = 'CoreData'
  s.resource_bundles = {
    'RamblerSpotlightDataBase' => ['RamblerSpotlight/Classes/CoreDataStack/DataModel/*.xcdatamodeld']
   }

end
