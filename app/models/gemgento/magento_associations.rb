module Gemgento
  class MagentoProductLinks < ActiveRecord::Base
    establish_connection :magento
    set_table_name 'mwcatalog_product_super_link'
  end
end