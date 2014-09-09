module Gemgento
  class StockNotification < ActiveRecord::Base
    validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
    validates :email, :name, :product_id, :product_name, :product_url, presence: true

    belongs_to :product, class_name: 'Gemgento::Product'

    before_create :push_to_magento

    def push_to_magento
      magento_product_id = Gemgento::Product.find(product_id).magento_id
      Gemgento::API::SOAP::StockNotification.add(magento_product_id, product_name, product_url, name, email, phone)
    end
  end
end
