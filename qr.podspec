

Pod::Spec.new do |s|

 

  s.name         = "qr"
  s.version      = "0.0.1"
  s.summary      = "Handle some data."
  s.description  = <<-DESC
                    Handle the data.
                   DESC

  s.homepage     = "http://csdn.net/veryitman"
  s.license      = "MIT"
  s.author             = { "veryitman" => "362675035@qq.com" }
  s.source =  { :path => '.' }
  s.source_files  = "Source", "**/**/*.{h,m,mm,c}"
  s.exclude_files = "Source/Exclude"
  s.resources = 'qr/resources/storyboard/**','qr/resources/image/**','qr/resources/xib/**'
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  

  
  s.dependency 'farwolf.weex'
 

end
