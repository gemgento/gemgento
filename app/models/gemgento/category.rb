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
    scope :navigation, -> { where(include_in_menu: true) }
    scope :root, -> { find_by(parent_id: nil) }
    scope :active, -> { where(is_active: true) }

    after_save :enforce_positioning, if: :position_changed?

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

        parent.children.where(is_active: true).each do |child|
          child_options << [child.name, child.id]

          if child.children.where(is_active: true)
            child.children.where(is_active: true).each do |second_child|
              child_options << [second_child.name, second_child.id]
            end
          end
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

    # Increment the position on all categories that come after.  Used to ensure correct positioning after changing the
    # position of a single category.
    #
    # @return [void]
    def enforce_positioning
      Gemgento::Category.skip_callback(:save, :after, :enforce_positioning)

      last_position = self.position
      categories = Gemgento::Category.where('parent_id = ? AND position >= ? AND id != ?', self.parent_id, self.position, self.id)
      categories.each do |category|
        break if category.position != last_position

        category.position = category.position + 1
        category.save

        last_position = category.position
      end

      Gemgento::Category.set_callback(:save, :after, :enforce_positioning)
    end

    # Returns list of ancestors, starting from parent until root.
    #
    #   subchild1.ancestors # => [child1, root]
    def ancestors
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end

  end
end
