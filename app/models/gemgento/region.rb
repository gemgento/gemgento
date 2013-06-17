module Gemgento
  class Region < ActiveRecord::Base
    belongs_to :country

    def self.index
      if Region.find(:all).size == 0
        API::SOAP::Directory::Region.fetch_all
      end

      Region.find(:all)
    end

  end
end