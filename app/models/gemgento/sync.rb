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
      Gemgento::API::SOAP::Catalog::ProductAttributeSet.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttribute.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types
    end

    def self.products
      last_updated = Sync.where('subject IN (?)', %w[products everything]).order('created_at DESC').first.created_at
      create_current('products')

      Gemgento::API::SOAP::Catalog::Product.fetch_all last_updated.to_s(:db)
    end

    def self.inventory
      Gemgento::API::SOAP::CatalogInventory::StockItem.fetch_all
    end

    def self.customers
      Gemgento::API::SOAP::Customer::Customer.fetch_all_customer_groups
      Gemgento::API::SOAP::Customer::Customer.fetch_all
      Gemgento::API::SOAP::Customer::Address.fetch_all
    end

    def self.addresses
      Gemgento::API::SOAP::Customer::Address.fetch_all
    end

    def self.everything
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
      Gemgento::API::SOAP::Customer::Address.fetch_all
      Gemgento::API::SOAP::Sales::Order.fetch_all
    end

    private

    def self.create_current(subject)
      current = Sync.new
      current.subject = subject
      current.save
    end
  end
end