module Gemgento
  class Cart::UpdateItemWorker
    include Sidekiq::Worker

    def perform(order_id, product_id, quantity, old_quantity, options)
      order = Gemgento::Order.find(order_id)
      product = Gemgento::Product.find(product_id)

    end
  end
end