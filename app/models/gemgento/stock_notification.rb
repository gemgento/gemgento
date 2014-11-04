module Gemgento

  # @author Gemgento LLC
  class StockNotification < ActiveRecord::Base
    validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
    validates :email, :name, :product_id, :product_name, :product_url, presence: true

    belongs_to :product, class_name: 'Product'

    before_create :push_to_magento

    def push_to_magento
      magento_product_id = Product.find(product_id).magento_id
      API::SOAP::StockNotification.add(magento_product_id, product_name, product_url, name, email, phone)
    end
  end
end
