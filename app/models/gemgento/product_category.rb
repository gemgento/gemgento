module Gemgento

  # @author Gemgento LLC
  class ProductCategory < ActiveRecord::Base
    include Gemgento::ProductTouches

    belongs_to :product
    belongs_to :category
    belongs_to :store

    touch :category, after_touch: :after_touch

    validates :product, :category, :store, presence: true
    validates :product, uniqueness: { scope: [:category, :store] }

    default_scope -> { order(:category_id, :position, :product_id, :id) }

    before_save :update_magento_category_product, if: -> { sync_needed }

    attr_accessor :sync_needed

    def update_magento_category_product
      response = API::SOAP::Catalog::Category.update_product(self)

      if response.success?
        self.sync_needed = false
        return true
      else
        errors.add(:base, response.body[:faultstring])
        
        if response.body[:faultstring] == "Requested product is not assigned to category."
          response = API::SOAP::Catalog::Category.assign_product(self)
          self.sync_needed = false
          return true
        else
          return false
        end
      end
    end
  end
end