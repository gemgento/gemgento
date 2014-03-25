module Gemgento

  # @author Gemgento LLC
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

    # Create a string representation of the path from the root to the Category.
    #
    # @return [String]
    def tree_path
      root = Gemgento::Category.root
      parent = self.parent
      path = self.name

      while parent != root do
        path = "#{parent.name} > #{path}"
        parent = parent.parent
      end

      return path
    end

    # Create an options array for use in an HTML select input.  Categories are grouped under top level scoped
    # categories.
    #
    # @return [Array(String, Array(Array(String, Integer)))]
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

    # Return the Category as JSON.
    #
    # @param options [Hash, nil]
    # @return [String]
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

    # Sets the deleted_at to the current timestamp.
    #
    # @return [void]
    def mark_deleted
      self.deleted_at = Time.now
    end

    # Marks the category as deleted as saves.
    #
    # @return [void]
    def mark_deleted!
      mark_deleted
      self.save
    end

  end
end