module Gemgento
  class SyncController < BaseController
    before_filter :ensure_no_active_product_sync, :except => [:busy, :orders, :everything]
    before_filter :ensure_no_active_order_sync, :except => [:busy, :products, :everything]

    def products
      Gemgento::Sync.attributes
      Gemgento::Sync.products
      Gemgento::Sync.inventory
      render :nothing => true
    end

    def orders
      Gemgento::Sync.customers
      Gemgento::Sync.orders
      render :nothing => true
    end

    def everything
      Gemgento::Sync.everything
      render :nothing => true
    end

    def busy
      render :nothing => true
    end

    private

    def ensure_no_active_product_sync
      return Gemgento::Sync.is_active? %w[attributes products inventory everything]
    end

    def ensure_no_active_order_sync
      return Gemgento::Sync.is_active? %w[customers orders everything]
    end

    def ensure_no_active_sync
      return Gemgento::Sync.is_active?
    end

  end
end