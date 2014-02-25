module Gemgento
  class Magento::MagentoBaseController < BaseController
    before_filter :validate_ip

    def validate_ip
      whitelist = Gemgento::Config[:magento][:ip_whitelist].split(',')

      puts request.remote_ip.inspect
      puts whitelist.inspect

      if Rails.env.production? && !whitelist.include?(request.remote_ip)
        raise ActionController::RoutingError.new('Not Found')
      end
    end

  end
end