yaml = YAML.load(File.read(Rails.root.join('config', 'gemgento_config.yml')))
Gemgento::Config = HashWithIndifferentAccess.new(yaml[Rails.env])
Gemgento::Sync.end_all

require 'open-uri'
require 'net/https'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      self.ca_file = "/etc/pki/tls/certs/ca-bundle.crt" # for Centos/Redhat
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end