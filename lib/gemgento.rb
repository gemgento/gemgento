require "gemgento/version"
require "gemgento/engine"
require 'exception_notifier'
require 'savon'

module Gemgento
  class Magento

    # Log into the Magento API and setup the session and client
    def self.api_login
      @api_url = "http://#{Gemgento::Config[:magento][:url]}/index.php/api/v#{Gemgento::Config[:magento][:api_version]}_#{Gemgento::Config[:magento][:api_type]}/?wsdl=1"
      @client = Savon.client(wsdl: @api_url, log: true)
      if Gemgento::Session.last.nil?
        response = @client.call(:login, message: { :username => Gemgento::Config[:magento][:username], :apiKey => Gemgento::Config[:magento][:api_key] })
        @session = response.body[:login_response][:login_return];
        s = Gemgento::Session.new
        s.session_id = @session
        s.save
      else
        @session = Gemgento::Session.last.session_id
      end
    end

    # Make an API call to Magento and get the response
    #
    # @param [Symbol] function  The API call to make
    # @param [Hash]   message   Call parameters (does not need session)
    # @return [Hash]
    def self.create_call(function, message = {})
      api_login if !defined? @client

      message[:sessionId] = @session

      begin
        response = @client.call(function, message: message)
      rescue
        puts "Call failed - #{function}"
        exit
        response = nil
      end

      return response
    end
  end

end
