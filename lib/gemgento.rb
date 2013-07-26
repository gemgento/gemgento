require 'gemgento/version'
require 'gemgento/engine'
require 'exception_notifier'
require 'gemgento/controller_helpers/order.rb'
require 'savon'
require 'builder'
require 'devise'

module Gemgento
  class Magento

    # Log into the Magento API and setup the session and client
    def self.api_login
      @api_url = "http://#{Gemgento::Config[:magento][:url]}/index.php/api/v#{Gemgento::Config[:magento][:api_version]}_#{Gemgento::Config[:magento][:api_type]}/index/wsdl/1"
      @client = Savon.client(
          wsdl: @api_url,
          log: Gemgento::Config[:magento][:debug],
          raise_errors: false,
          basic_auth: [Gemgento::Config[:magento][:auth_username].to_s, Gemgento::Config[:magento][:auth_password].to_s]
      )

      if Gemgento::Session.last.nil?
        response = @client.call(:login, message: {:username => Gemgento::Config[:magento][:username], :apiKey => Gemgento::Config[:magento][:api_key]})

        unless response.success?
          puts 'Login Failed - Check Session'
          exit
        end

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
      Rails.logger.debug "Making Call - #{function}"

      response = @client.call(function, message: message)

      magento_response = MagentoResponse.new
      magento_response.request = {function: function, message: message}

      if response.success?
        magento_response.success = true
        magento_response.body = response.body[:"#{function}_response"]
        Rails.logger.debug '^^^ Success ^^^'
      else
        magento_response.success = false
        magento_response.body = response.body[:fault]
        Rails.logger.warn '^^^ Failure ^^^'
      end

      Rails.logger.debug '-------------------'

      magento_response.save

      return magento_response
    end

    def self.enforce_savon_string(subject)
      if subject.is_a? String
        subject
      else
        ''
      end
    end
  end

end
