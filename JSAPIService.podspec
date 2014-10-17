Pod::Spec.new do |s|
  s.name     = 'JSAPIService'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'JSAPIService supply a framework to create JSAPI for developer'
  s.homepage = 'https://git.ms.netease.com/huipang/commonjsapi.git'
  s.authors  = { 'huipang' => 'huipang@corp.netease.com' }
  s.source   = { :git => 'https://git.ms.netease.com/huipang/commonjsapi.git', :tag => "1.0.0"}
  s.requires_arc = true

  s.platform = :ios
  s.ios.deployment_target = '5.0'
  s.ios.public_header_files = 'CommonJSAPI/LDJSService/*.h'
  s.ios.source_files = 'CommonJSAPI/LDJSService/*.{h,m}'

  s.subspec 'CDVCore' do |ss|
    ss.ios.deployment_target = '5.0'
    ss.ios.public_header_files = 'CommonJSAPI/LDJSService/CDVCore/*.h'
    ss.ios.source_files = 'CommonJSAPI/LDJSService/CDVCore'
  end

end
