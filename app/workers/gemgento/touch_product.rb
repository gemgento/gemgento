module Gemgento
  class TouchProduct
    include Sidekiq::Worker
    sidekiq_options backtrace: true

    # Touch products in background task.
    #
    # @param [Array(Integer)] product_ids
    # @param [Boolean] affects_cache_expiration
    # @return [Void]
    def perform(product_ids, affects_cache_expiration = false)
      Gemgento::Product.skip_callback(:save, :before, :create_magento_product)
      Gemgento::Product.skip_callback(:save, :before, :update_magento_product)

      Gemgento::Product.where(id: product_ids).each do |product|
        next if product.sync_needed = true

        if affects_cache_expiration
          product.set_cache_expires_at
        else
          product.updated_at = Time.now
          product.save
        end
      end

      Gemgento::Product.set_callback(:save, :before, :create_magento_product)
      Gemgento::Product.set_callback(:save, :before, :update_magento_product)
    end
  end
end