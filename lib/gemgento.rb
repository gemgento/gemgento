require 'devise'
require 'savon'
require 'exception_notifier'
require 'builder'
require 'gemgento/version'
require 'gemgento/engine'
require 'gemgento/controller_helpers/order.rb'

module Gemgento
  class Magento

    # Log into the Magento API and setup the session and client
    def self.api_login(force_new_session = false)
      @api_url = "http://#{Gemgento::Config[:magento][:url]}/index.php/api/v#{Gemgento::Config[:magento][:api_version]}_#{Gemgento::Config[:magento][:api_type]}/index/wsdl/1"
      @client = Savon.client(
          wsdl: @api_url,
          log: Gemgento::Config[:magento][:debug],
          raise_errors: false,
          basic_auth: [Gemgento::Config[:magento][:auth_username].to_s, Gemgento::Config[:magento][:auth_password].to_s]
      )

      if Gemgento::Session.last.nil? || force_new_session
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

      magento_response = MagentoResponse.new
      magento_response.request = {function: function, message: function == :catalog_product_attribute_media_create ? '' : message}

      response = @client.call(function, message: message)

      if response.success?
        magento_response.success = true
        magento_response.body = response.body[:"#{function}_response"]
        Rails.logger.debug '^^^ Success ^^^'
      else
        magento_response.success = false
        magento_response.body = response.body[:fault]
        Rails.logger.warn '^^^ Failure ^^^'

        if !magento_response.body[:faultcode].nil? && magento_response.body[:faultcode].to_i == 5
          Rails.logger.debug '--- Attempting To Start New Session ---'
          api_login(true)
          create_call(function, message)
        end
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
