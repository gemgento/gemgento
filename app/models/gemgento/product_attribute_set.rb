module Gemgento
  class ProductAttributeSet < ActiveRecord::Base
    has_many :product_attributes
    has_many :products

    def self.index
      if ProductAttributeSet.find(:all).size == 0
        API::SOAP::Catalog::ProductAttributeSet.fetch_all
      end

      ProductAttributeSet.find(:all)
    end

  end
end