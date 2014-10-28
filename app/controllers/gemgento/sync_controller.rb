module Gemgento
  class SyncController < ApplicationController
    before_filter :ensure_no_active_product_sync, :except => [:busy, :orders, :everything]
    before_filter :ensure_no_active_order_sync, :except => [:busy, :products, :everything]

    def products
      Sync.categories
      Sync.attributes
      Sync.products
      Sync.inventory
      render :nothing => true
    end

    def orders
      Sync.customers
      Sync.orders
      render :nothing => true
    end

    def everything
      Sync.everything
      render :nothing => true
    end

    def busy
      render :nothing => true
    end

    private

    def ensure_no_active_product_sync
      if Sync.is_active? %w[categories attributes products inventory everything]
        redirect_to '/sync/busy'
      end
    end

    def ensure_no_active_order_sync
      if Sync.is_active? %w[customers orders everything]
        redirect_to '/sync/busy'
      end
    end

    def ensure_no_active_sync
      if Sync.is_active?
        redirect_to '/sync/busy'
      end
    end

  end
end