module Gemgento
  class Category < ActiveRecord::Base
    has_many :product_categories
    has_many :products, -> { distinct }, through: :product_categories
    has_many :children, foreign_key: 'parent_id', class_name: 'Category'

    belongs_to :parent, foreign_key: 'parent_id', class_name: 'Category'

    has_and_belongs_to_many :stores, -> { distinct }, join_table: 'gemgento_categories_stores', class_name: 'Store'

    has_attached_file :image

    after_save :sync_local_to_magento

    attr_accessor :includes_category_products

    default_scope -> { order(:position) }

    scope :top_level, -> { where(:parent_id => 2) }

    def save
      # Dirty dirty dirty(S3Bug)..
      begin
        super
      rescue Exception => e
        puts 'Upload Failed once..'

        begin
          super
        rescue Exception => e
          puts 'Upload Failed twice..'

          begin
            super
          rescue Exception => e
            puts 'Upload Failed three times..'

            super
          end
        end
      end
    end

    def self.index
      if Category.all.size == 0
        API::SOAP::Catalog::Category.fetch_all
      end
      Category.all
    end

    def as_json(options = nil)
      if options.nil? || options[:store].nil?
        store = Gemgento::Store.current
      else
        store = options[:store]
      end

      result = super

      if self.includes_category_products
        result['products'] = self.products.active.catalog_visible.as_json({ store: store })
      end

      return result
    end

  end
end