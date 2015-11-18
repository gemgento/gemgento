module Gemgento

  # @author Gemgento LLC
  class Sync < ActiveRecord::Base
    scope :active, -> { where(is_complete: false) }

    def self.locations
      Gemgento::API::SOAP::Directory::Country.fetch_all
      Gemgento::API::SOAP::Directory::Region.fetch_all
    end

    def self.stores
      Gemgento::API::SOAP::Miscellaneous::Store.fetch_all
    end

    def self.categories
      current = create_current('categories')

      Gemgento::API::SOAP::Catalog::Category.fetch_all
      Gemgento::API::SOAP::Catalog::Category.set_product_categories

      current.complete
    end

    def self.attributes
      current = create_current('attributes')

      Gemgento::API::SOAP::Catalog::ProductAttributeSet.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttribute.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types

      current.complete
    end

    def self.products(skip_existing = false)
      last_updated = Sync.where('subject IN (?) AND is_complete = ?', %w[products everything], 1).order('created_at DESC').first
      last_updated = last_updated.created_at.to_s(:db) unless last_updated.nil?
      current = create_current('products')

      Gemgento::API::SOAP::Catalog::Product.fetch_all last_updated
      Gemgento::API::SOAP::Catalog::Category.set_product_categories

      current.complete
    end

    def self.inventory
      current = create_current('inventory')
      Gemgento::API::SOAP::CatalogInventory::StockItem.fetch_all
      current.complete
    end

    def self.customers
      last_updated = Sync.where('subject IN (?) AND is_complete = ?', %w[customers everything], 1).order('created_at DESC').first
      last_updated = last_updated.created_at.to_s(:db) unless last_updated.nil?
      current = create_current('customers')

      Gemgento::API::SOAP::Customer::Customer.fetch_all_customer_groups
      Gemgento::API::SOAP::Customer::Customer.fetch_all(last_updated_filter(last_updated))

      current.complete
    end

    def self.orders
      last_updated = Sync.where('subject IN (?) AND is_complete = ?', %w[orders everything], 1).order('created_at DESC').first
      last_updated = last_updated.created_at.to_s(:db) unless last_updated.nil?
      current = create_current('orders')

      Gemgento::API::SOAP::Sales::Order.fetch_all last_updated

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
      Gemgento::API::SOAP::Catalog::Category.set_product_categories
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

    def self.is_active?(subject = nil)
      if subject.nil?
        return !Sync.active.empty?
      else
        return !Sync.where('subject IN (?)', subject).active.empty?
      end
    end

    def self.end_all
      Sync.update_all('is_complete = 1')
    end

    private

    def self.create_current(subject)
      current = Sync.new
      current.subject = subject
      current.is_complete = false
      current.save
      current
    end

    def self.last_updated_filter(last_updated)
      {
          'complex_filter' => {
              item: [
                key: 'updated_at',
                value: {
                    key: 'gt',
                    value: last_updated
                }
            ]
          }
      }
    end
  end
end