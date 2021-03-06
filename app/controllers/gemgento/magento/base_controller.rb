module Gemgento
  module Magento
    class BaseController < Gemgento::ApplicationController

      skip_before_action :verify_authenticity_token
      before_filter :validate_ip

      def validate_ip
        whitelist = Config[:magento][:ip_whitelist].to_s.split(',').map(&:strip)

        if Rails.env.production? && !whitelist.include?(request.remote_ip.to_s)
          raise ActionController::RoutingError.new('Not Found')
        end
      end

    end
  end
end