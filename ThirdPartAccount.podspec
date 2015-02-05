#
# Be sure to run `pod lib lint ThirdPartAccount.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ThirdPartAccount"
  s.version          = "0.1.0"
  s.summary          = "ThirdPartAccount"
  s.description      = "ThirdPartAccount: QQ, Weibo, etc"
  s.homepage         = "https://github.com/chuangyi0128/ThirdPartAccount"
  s.license          = 'MIT'
  s.author           = { "SongLi" => "chuangyi0128@gmail.com" }
  s.source           = { :git => "https://github.com/chuangyi0128/ThirdPartAccount.git", :tag => s.version.to_s }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'ThirdPartAccount'
  s.resources = 'ThirdPartAccount/TPAAcoutSerivece.bundle'
  s.frameworks = 'MessageUI'

  s.dependency 'QQSDK'
  s.dependency 'WeChatSDK'
  s.dependency 'SinaWeiboSDK'

  s.dependency 'UIImage-Resize'
  s.dependency 'ERActionSheet'
  s.dependency 'UICategory'
end
