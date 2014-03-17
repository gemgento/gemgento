module Gemgento
  class Magento::MagentoBaseController < ApplicationController
    before_filter :validate_ip

    def validate_ip
      whitelist = Gemgento::Config[:magento][:ip_whitelist].to_s.split(',')

      if Rails.env.production? && !whitelist.include?(request.remote_ip.to_s)
        raise ActionController::RoutingError.new('Not Found')
      end
    end

  end
end