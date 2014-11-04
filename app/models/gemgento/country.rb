module Gemgento

  # @author Gemgento LLC
  class Country < ActiveRecord::Base
    has_many :regions

    default_scope -> { order :name }

    # JSON representation of the Country.
    #
    # @param options [Hash]
    # @return [Hash]
    def as_json(options = nil)
      result = super
      result[:regions] = self.regions if self.regions.loaded?

      return result
    end

  end
end