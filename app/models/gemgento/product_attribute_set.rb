module Gemgento
  class ProductAttributeSet < ActiveRecord::Base
    has_and_belongs_to_many :product_attributes, -> { uniq },
                            :join_table => 'gemgento_attribute_set_attributes'
    has_many :products

    default_scope -> { where(deleted_at: nil) }

    def mark_deleted
      self.deleted_at = Time.now
    end

    def mark_deleted!
      mark_deleted
      self.save
    end

  end
end