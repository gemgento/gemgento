module Gemgento
  class ProductAttributeSet < ActiveRecord::Base
    has_and_belongs_to_many :product_attributes, -> { uniq },
                            :join_table => 'gemgento_attribute_set_attributes',
                            foreign_key: 'attribute_set_id',
                            association_foreign_key: 'attribute_id'
    has_many :products

    def self.index
      if ProductAttributeSet.all.size == 0
        API::SOAP::Catalog::ProductAttributeSet.fetch_all
      end

      ProductAttributeSet.all
    end

  end
end