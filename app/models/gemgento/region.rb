module Gemgento
  class Region < ActiveRecord::Base
    belongs_to :country

    default_scope -> { order(:name) }

    def self.index
      if Region.all.size == 0
        API::SOAP::Directory::Region.fetch_all
      end

      Region.all
    end

  end
end