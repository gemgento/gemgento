module Gemgento
  class MagentoResponse < ActiveRecord::Base
    serialize :request, Hash
    serialize :body, Hash

    def success?
      self.success
    end

  end
end