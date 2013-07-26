module Gemgento
  class MagentoResponse < ActiveRecord::Base

    def success?
      self.success
    end

  end
end