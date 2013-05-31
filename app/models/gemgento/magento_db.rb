module Gemgento
  class MagentoDB < ActiveRecord::Base
    establish_connection(:magento)

    def self.product_links(parent_id)
      self.table_name = 'catalog_product_super_link'
      puts self.where('parent_id = ?', parent_id)
    end
  end
end