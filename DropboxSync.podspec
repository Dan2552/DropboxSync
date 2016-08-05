Pod::Spec.new do |s|
  s.name             = 'DropboxSync'
  s.version          = '0.2.1'
  s.summary          = 'A easy to implement protocol based sync library build ontop of SwiftyDropbox'

  s.description      = <<-DESC
By implementing the DropboxSyncable protocol methods in your class will make the class syncable via Dropbox.
                       DESC

  s.homepage         = 'https://github.com/Dan2552/DropboxSync'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Inkpen' => 'dan2552@gmail.com' }
  s.source           = { :git => 'https://github.com/Dan2552/DropboxSync.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Dan2552'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DropboxSync/Classes/**/*'

  s.dependency 'SwiftyDropbox', '~> 3.1'
  s.dependency 'SwiftyJSON', '~> 2.3'
end
