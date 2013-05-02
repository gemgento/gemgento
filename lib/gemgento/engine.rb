require 'rails/engine'

module Gemgento
  class Engine < ::Rails::Engine
    isolate_namespace Gemgento
    engine_name 'gemgento'
    
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
    end

    def api_login
      @api_url = 'http://'+Gemgento::Config[:magento][:url]+'/api/v2_soap/index?wsdl'
      client = Savon.client(wsdl: @api_url, log: true)
      if Gemgento::Session.last.nil?        
        response = client.call(:login, message: { :username => 'maui', :apiKey => '857123FHDShfd' })
        if response.success? == false
          puts "login failed"
          System.exit(0)
        end
        session = response.body[:login_response][:login_return];
        s = Gemgento::Session.new
        s.session_id = session
        s.save
      else
        session = Gemgento::Session.last.session_id
      end      
    end
        
  end
end