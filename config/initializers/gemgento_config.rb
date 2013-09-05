yaml = YAML.load(File.read(Rails.root.join('config', 'gemgento_config.yml')))
Gemgento::Config = HashWithIndifferentAccess.new(yaml[Rails.env])
Gemgento::Sync.end_all