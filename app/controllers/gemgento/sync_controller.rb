module Gemgento
  class SyncController < BaseController

    def products
      Gemgento::Sync.attributes
      Gemgento::Sync.products
      Gemgento::Sync.inventory
    end

    def orders
      Gemgento::Sync.customers
      Gemgento::Sync.orders
    end

    def complete
      Gemgento::Sync.everything
    end

  end
end