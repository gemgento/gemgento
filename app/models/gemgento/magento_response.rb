module Gemgento
  class MagentoResponse < ActiveRecord::Base
    serialize :request, Hash
    serialize :body, Hash

    attr_accessor :body_overflow

    def success?
      self.success
    end

  end
end