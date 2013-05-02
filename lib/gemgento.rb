require "gemgento/version"
require "gemgento/engine"
require 'exception_notifier'
require 'savon'

module Gemgento
  class Magento
    def self.api_login
      @api_url = 'http://'+Gemgento::Config[:magento][:url]+'/api/v2_soap/index?wsdl'
      client = Savon.client(wsdl: @api_url, log: true)
      if Gemgento::Session.last.nil?        
        response = client.call(:login, message: { :username => 'maui', :apiKey => '432sdhfaFDHSDF' })
        if response.success? == false
          puts "login failed"
          System.exit(0)
        end
        @session = response.body[:login_response][:login_return];
        s = Gemgento::Session.new
        s.session_id = @session
        s.save
      else
        @session = Gemgento::Session.last.session_id
      end      
      return client
    end
  end

end
