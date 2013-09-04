module Gemgento
  class Sync < ActiveRecord::Base

    def self.locations
      Gemgento::API::SOAP::Directory::Country.fetch_all
      Gemgento::API::SOAP::Directory::Region.fetch_all
    end

    def self.stores
      Gemgento::API::SOAP::Miscellaneous::Store.fetch_all
    end

    def self.categories
      Gemgento::API::SOAP::Catalog::Category.fetch_all
    end

    def self.attributes
      current = create_current('attributes')

      Gemgento::API::SOAP::Catalog::ProductAttributeSet.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttribute.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types

      current.complete
    end

    def self.products
      last_updated = Sync.where('subject IN (?)', %w[products everything]).order('created_at DESC').first.created_at
      current = create_current('products')

      Gemgento::API::SOAP::Catalog::Product.fetch_all last_updated.to_s(:db)

      current.complete
    end

    def self.inventory
      current = create_current('inventory')
      Gemgento::API::SOAP::CatalogInventory::StockItem.fetch_all
      current.complete
    end

    def self.customers
      last_updated = Sync.where('subject IN (?)', %w[customers everything]).order('created_at DESC').first.created_at
      current = create_current('customers')

      Gemgento::API::SOAP::Customer::Customer.fetch_all_customer_groups
      Gemgento::API::SOAP::Customer::Customer.fetch_all last_updated.to_s(:db)

      current.complete
    end

    def self.orders
      last_updated = Sync.where('subject IN (?)', %w[orders everything]).order('created_at DESC').first.created_at
      current = create_current('orders')

      Gemgento::API::SOAP::Sales::Order.fetch_all last_updated.to_s(:db)

      current.complete
    end

    def self.everything
      current = create_current('everything')

      Gemgento::API::SOAP::Directory::Country.fetch_all
      Gemgento::API::SOAP::Directory::Region.fetch_all
      Gemgento::API::SOAP::Miscellaneous::Store.fetch_all
      Gemgento::API::SOAP::Catalog::Category.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeSet.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttribute.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types
      Gemgento::API::SOAP::Catalog::Product.fetch_all
      Gemgento::API::SOAP::CatalogInventory::StockItem.fetch_all
      Gemgento::API::SOAP::Customer::Customer.fetch_all_customer_groups
      Gemgento::API::SOAP::Customer::Customer.fetch_all
      Gemgento::API::SOAP::Sales::Order.fetch_all

      current.complete
    end

    def complete
      self.is_complete = true
      self.save
    end

    private

    def self.create_current(subject)
      current = Sync.new
      current.subject = subject
      current.save
      current
    end
  end
end