module Gemgento
  class Magento
    # Log into the Magento API and setup the session and client
    def self.api_login(force_new_session = false)
      @client = Savon.client(client_config)
      @session = Gemgento::Session.get(@client, force_new_session)
    end

    def self.client_config
      config = {
        wsdl: "#{Gemgento::Config[:magento][:url]}/index.php/api/v#{Gemgento::Config[:magento][:api_version]}_#{Gemgento::Config[:magento][:api_type]}/index/wsdl/1",
        log: Gemgento::Config[:magento][:debug],
        raise_errors: false,
        open_timeout: 300,
        read_timeout: 300
      }

      if !Gemgento::Config[:magento][:auth_username].blank? && !Gemgento::Config[:magento][:auth_password].blank?
        config[:basic_auth] = [Gemgento::Config[:magento][:auth_username].to_s, Gemgento::Config[:magento][:auth_password].to_s]
      end

      return config
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

      # don't save some messages because they are just too big!
      if [:catalog_product_attribute_media_create].include? function
        magento_response.request = {function: function, message: ''}
      else
        magento_response.request = {function: function, message: message}
      end

      response = @client.call(function, message: message)

      if response.success?
        magento_response.success = true

        if [:customer_customer_list, :sales_order_list, :catalog_product_list].include? function
          magento_response.body = response.body[:"body_too_big"]
          magento_response.body_overflow = response.body[:"#{function}_response"]
        else
          magento_response.body = response.body[:"#{function}_response"]
        end

        # only save successful responses if debugging is enabled
        magento_response.save if Gemgento::Config[:magento][:debug]

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

        magento_response.save
      end

      magento_response.body = replace_empty_strings(magento_response.body)
      magento_response.body_overflow = replace_empty_strings(magento_response.body_overflow) unless magento_response.body_overflow.nil?

      return magento_response
    end

    def self.replace_empty_strings(subject)
      if subject == { :'@xsi:type' => 'xsd:string' }
        return ''
      elsif subject.is_a?(Array)
        return subject.map{ |child| replace_empty_strings(child) }
      elsif subject.is_a?(Hash)
        return subject.each{ |key, value| subject[key] = replace_empty_strings(value) }
      else
        return subject
      end
    end

    def self.enforce_savon_string(subject)
      if subject.is_a? String
        subject
      else
        ''
      end
    end

    def self.enforce_savon_array(subject)
      if subject.is_a? Array
        subject
      else
        [subject]
      end
    end
  end
end