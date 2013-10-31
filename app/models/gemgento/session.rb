module Gemgento
  class Session < ActiveRecord::Base

    def self.get(client, force_new_session)
      if Session.last.nil? || Session.last.expired || force_new_session
        response = client.call(:login, message: {:username => Gemgento::Config[:magento][:username], :apiKey => Gemgento::Config[:magento][:api_key]})

        unless response.success?
          puts 'Login Failed - Check Session'
          exit # cannot recover from this
        end

        session = response.body[:login_response][:login_return];

        s = Gemgento::Session.new
        s.session_id = session
        s.save
      else
        s = Gemgento::Session.last
        s.touch

        session = s.session_id
      end

      return session
    end

    def expired
      if self.updated_at <= timeout.seconds.ago
        return true
      else
        return false
      end
    end

    private

    def timeout
      if Gemgento::Config[:magento][:session_life].nil?
        return 24 * 60 # default of 24 minutes, determined by PHP
      else
        return Gemgento::Config[:magento][:session_life].to_i
      end
    end

  end
end