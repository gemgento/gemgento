# create a default configuration file if none exists
unless File.exist?(Rails.root.join('config', 'gemgento_config.yml'))
  File.open(Rails.root.join('config', 'gemgento_config.yml'), 'w') do |f|
    f.write({
                development: {
                    magento: {
                        url: 'www.gemgento.com',
                        username:         'gemgento',
                        api_key:          '',
                        encryption:       '',
                        debug:            false,
                    },
                },
                beta: {
                    magento: {
                        url: 'www.gemgento.com',
                        username:         'gemgento',
                        api_key:          '',
                        encryption:       '',
                    },
                },
                production: {
                    magento: {
                        url: 'www.gemgento.com',
                        username:         'gemgento',
                        api_key:          '',
                        encryption:       '',
                        ip_whitelist:     '127.0.0.1'
                    },
                }
            }.to_yaml)
  end
end

# load the configuation file
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
        ip_whitelist:     '127.0.0.1'
    },
    sellect: false
}

# create the configuration hash from environment specifics in configuration file
Gemgento::Config = HashWithIndifferentAccess.new(config_defaults).deep_merge HashWithIndifferentAccess.new(yaml[Rails.env])

# Don't open files as StringIO
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0