module Gemgento
  class Category < ActiveRecord::Base
    has_many :product_categories
    has_many :products, -> { distinct }, through: :product_categories
    has_many :children, foreign_key: 'parent_id', class_name: 'Category'

    belongs_to :parent, foreign_key: 'parent_id', class_name: 'Category'

    has_and_belongs_to_many :stores, -> { distinct }, join_table: 'gemgento_categories_stores', class_name: 'Store'

    has_attached_file :image

    attr_accessor :includes_category_products

    default_scope -> { where(deleted_at: nil).order(:position) }

    scope :top_level, -> { where(parent: Gemgento::Category.find_by(parent_id: nil), is_active: true) }
    scope :root, -> { find_by(parent_id: nil) }

    def tree_path
      path = self.name

      parent = self.parent
      while parent != nil? && parent.parent != nil do
        path = "#{parent.name} > #{path}"
        parent = parent.parent
      end

      return path
    end

    def self.grouped_options
      options = []

      Gemgento::Category.top_level.each do |parent|

        child_options = [["#{parent.name} (parent)", parent.id]]
        parent.children.each do |child|
          child_options << [child.name, child.id]
        end

        options << [parent.name, child_options]
      end

      return options
    end

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

    def mark_deleted
      self.deleted_at = Time.now
    end

    def mark_deleted!
      mark_deleted
      self.save
    end

  end
end