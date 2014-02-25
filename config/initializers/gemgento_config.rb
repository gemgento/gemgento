yaml = YAML.load(File.read(Rails.root.join('config', 'gemgento_config.yml')))

# configuration settings
config_defaults = {
  magento: {
    url: 'www.gemgento.com',
    auth_username: '',
    auth_password: '',
    username:         'gemgento',
    api_key:          '',
    api_type:         'soap',
    api_version:      '2',
    encryption:       '',
    debug:            false,
    root:             '/var/www/magento/public',
    ip_whitelist:     '127.0.0.01'
  },
  sellect: false
}

Gemgento::Config = HashWithIndifferentAccess.new(yaml[Rails.env]).reverse_merge config_defaults

# Don't open files as StringIO
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0