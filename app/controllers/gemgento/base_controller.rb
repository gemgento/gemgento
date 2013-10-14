module Gemgento
  class BaseController < ActionController::Base
    include SslRequirement

    layout -> { set_layout 'application' }

    def set_layout(layout = 'application')
      if request.url # Check if we are redirected
        response.headers['X-PJAX-URL'] = request.url
      end

      if request.headers['X-PJAX']
        false
      else
        'application'
      end
    end
  end
end

