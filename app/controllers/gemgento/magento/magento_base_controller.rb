module Gemgento
  class Magento::MagentoBaseController < BaseController
    before_filter :validate_ip

    def validate_ip
      whitelist = Gemgento::Config[:magento][:ip_whitelist].split(',')

      if Rails.env.production? && !whitelist.include?(require.remote_ip)
        raise ActionController::RoutingError.new('Not Found')
      end
    end

  end
end