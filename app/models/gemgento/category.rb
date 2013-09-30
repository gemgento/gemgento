module Gemgento
  class Category < ActiveRecord::Base
    has_many :product_categories
    has_many :products, -> { distinct }, through: :product_categories

    belongs_to :parent, foreign_key: 'parent_id', class_name: 'Category'

    after_save :sync_local_to_magento

    scope :top_level, lambda { where(:parent_id => 2) }

    def self.index
      if Category.all.size == 0
        API::SOAP::Catalog::Category.fetch_all
      end
      Category.all
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