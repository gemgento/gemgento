module Gemgento
  class Country < ActiveRecord::Base
    has_many :regions

    default_scope -> { order(:name) }

    def self.index
      if Country.all.size == 0
        API::SOAP::Directory::Country.fetch_all
      end

      Country.all
    end

    def as_json(options = nil)
      result = super
      result[:regions] = self.regions

      return result
    end

  end
end