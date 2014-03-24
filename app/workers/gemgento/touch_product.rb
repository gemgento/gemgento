module Gemgento
  class TouchProduct
    include Sidekiq::Worker

    def perform(product_ids)
      Gemgento::Product.skip_callback(:save, :after, :sync_local_to_magento)

      Gemgento::Product.unscoped.where(id: product_ids).each do |product|
        product.updated_at = Time.now
        product.save
      end

      Gemgento::Product.set_callback(:save, :after, :sync_local_to_magento)
    end
  end
end