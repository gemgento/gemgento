yaml = YAML.load(File.read(Rails.root.join('config', 'gemgento_config.yml')))
Gemgento::Config = HashWithIndifferentAccess.new(yaml[Rails.env])

# Don't open files as StringIO
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0