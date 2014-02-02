module Gemgento
  class TouchProduct
    include Sidekiq::Worker

    def perform(product_ids)
      puts product_ids.inspect
      Gemgento::Product.skip_callback(:save, :after, :sync_local_to_magento)
      Gemgento::Product.where(id: product_ids).update_all(updated_at: Time.now)
      Gemgento::Product.set_callback(:save, :after, :sync_local_to_magento)
    end
  end
end