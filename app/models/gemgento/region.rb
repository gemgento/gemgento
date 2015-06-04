module Gemgento

  # @author Gemgento LLC
  class Region < ActiveRecord::Base
    belongs_to :country

    default_scope -> { order(:name, :code) }

    def name
      super.nil? ? self.code : super
    end

  end
end