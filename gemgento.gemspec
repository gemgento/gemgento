# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemgento/version'

Gem::Specification.new do |gem|
  gem.name          = "gemgento"
  gem.version       = Gemgento::VERSION
  gem.authors       = ["Philip Vasilevski"]
  gem.email         = ["phil@mauinewyork.com"]
  gem.description   = %q{rails based ecommerce for fashion and luxury}
  gem.summary       = %q{first version of sellect ecommerce platform}
  gem.homepage      = "http://sellect.co"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'exception_notification_rails3', '=1.2.0'
  gem.add_dependency 'savon'
end
