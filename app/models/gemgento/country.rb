module Gemgento
  class Country < ActiveRecord::Base
    has_many :regions

    def self.index
      if Country.find(:all).size == 0
        API::SOAP::Directory::Country.fetch_all
      end

      Country.find(:all)
    end

  end
end