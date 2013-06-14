module Gemgento
  class Category < ActiveRecord::Base
    has_and_belongs_to_many :products, -> { uniq } , :join_table => 'gemgento_categories_products'
    after_save :sync_local_to_magento

    def self.index
      if Category.find(:all).size == 0
        API::SOAPv2::Catalog::Category.fetch_all
      end
      Category.find(:all)
    end

  end
end