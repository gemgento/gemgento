module Gemgento
  class Category < ActiveRecord::Base
    has_and_belongs_to_many :products, -> { uniq } , :join_table => 'gemgento_categories_products'
    after_save :sync_local_to_magento

    def self.index
      if Category.find(:all).size == 0
        API::SOAP::Catalog::Category.fetch_all
      end
      Category.find(:all)
    end

    private

    # Synchronize the category with Magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          API::SOAP::Catalog::Category.create(self)
        else
          API::SOAP::Catalog::Category.update(self)
        end
      end
    end

  end
end