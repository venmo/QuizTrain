Pod::Spec.new do |spec|
  spec.name         = "QuizTrain"
  spec.version      = "3.0.0"
  spec.summary      = "QuizTrain is a framework created at Venmo allowing you to interact with TestRail's API using Swift."
  spec.homepage     = "https://github.com/venmo/QuizTrain"
  spec.license      = "MIT"
  spec.author             = { "Venmo" => "Venmo" }
  
  # Or just: spec.author    = "Venmo"
  # spec.authors            = { "Venmo" => "" }
  # spec.social_media_url   = "https://twitter.com/Venmo"

  spec.ios.deployment_target = "11.0"
  spec.osx.deployment_target = "10.12"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target = "10.0"
  
  spec.swift_version = '5.0'

  spec.source       = { :git => "https://github.com/venmo/QuizTrain.git", :tag => spec.version }

  spec.source_files  = "QuizTrain", "QuizTrain/**/*.{swift}"
  spec.exclude_files = "QuizTrain/Exclude"

end
