require "gemgento/version"
require "gemgento/engine"
require 'exception_notifier'
require 'savon'

module Gemgento
  class Magento
    def self.api_login
      @api_url = "http://#{Gemgento::Config[:magento][:url]}/api/v#{Gemgento::Config[:magento][:api_version]}_#{Gemgento::Config[:magento][:api_type]}/index?wsdl=1"
      client = Savon.client(wsdl: @api_url, log: true)
      if Gemgento::Session.last.nil?        
        response = client.call(:login, message: { :username => Gemgento::Config[:magento][:username], :apiKey => Gemgento::Config[:magento][:api_key] })
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
