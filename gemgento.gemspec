# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemgento/version'

Gem::Specification.new do |gem|
  gem.name          = "gemgento"
  gem.version       = Gemgento::VERSION
  gem.authors       = ["Philip Vasilevski"]
  gem.email         = ["phil@mauinewyork.com"]
  gem.description   = %q{rails based magento bridge for ecommerce}
  gem.summary       = %q{gemgento rails magento integration ecommerce platform}
  gem.homepage      = "http://gemgento.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'exception_notification_rails3', '=1.2.0'
  gem.add_dependency 'savon', '=2.2.0'
  gem.add_dependency 'spreadsheet', '=0.8.5'
  gem.add_dependency 'paperclip', '=3.4.1'
end
