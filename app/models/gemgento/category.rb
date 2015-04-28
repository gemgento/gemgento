module Gemgento

  # @author Gemgento LLC
  class Category < ActiveRecord::Base
    has_many :product_categories
    has_many :products, -> { distinct }, through: :product_categories
    has_many :children, foreign_key: 'parent_id', class_name: 'Category'

    has_one :shopify_adapter, class_name: 'Adapter::ShopifyAdapter', as: :gemgento_model

    belongs_to :parent, foreign_key: 'parent_id', class_name: 'Category'

    has_and_belongs_to_many :stores, -> { distinct }, join_table: 'gemgento_categories_stores', class_name: 'Store'

    has_attached_file :image

    default_scope -> { where(deleted_at: nil).order(:position) }

    scope :top_level, -> { where(parent: Category.find_by(parent_id: nil), is_active: true) }
    scope :navigation, -> { where(include_in_menu: true) }
    scope :root, -> { find_by(parent_id: nil) }
    scope :active, -> { where(is_active: true) }

    validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

    after_save :enforce_positioning, if: :position_changed?

    before_save :create_magento_category, if: -> { magento_id.nil? }
    before_save :update_magento_category, if: -> { sync_needed? && !magento_id.nil? }

    # Create a string representation of the path from the root to the Category.
    #
    # @return [String]
    def tree_path
      root = Category.root
      parent = self.parent.includes(:parent)
      path = self.name

      while !parent.nil? && parent != root do
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

        parent.children.where(is_active: true, parent: parent).each do |child|
          child_options << [child.name, child.id]
          child_options << grouped_option(child) if child.children.where(is_active: true).any?
        end

        options << [parent.name, child_options]
      end

      return options
    end

    # Get the option value and any subsequent child values as a path.
    #
    # @param category [Gemgento::Category]
    # @return [Array(String, Integer)]
    def self.grouped_option(category)
      options = []

      category.children.where(is_active: true, parent: category).each do |child|
        options << [child.name, child.id]

        child.children.where(is_active: true).each do |nested_child|
          path = nested_child.tree_path
          path = path.slice((path.index("> #{child.name} >") + 2)..-1)
          options << [path, nested_child.id]
        end
      end

      return options
    end

    # Sets the deleted_at to the current timestamp.
    #
    # @return [void]
    def mark_deleted
      self.deleted_at = Time.now
      self.shopify_adapter.destroy if self.shopify_adapter
    end

    # Marks the category as deleted and saves.
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
      Category.skip_callback(:save, :after, :enforce_positioning)

      last_position = self.position
      categories = Category.where('parent_id = ? AND position >= ? AND id != ?', self.parent_id, self.position, self.id)
      categories.each do |category|
        break if category.position != last_position

        category.position = category.position + 1
        category.save

        last_position = category.position
      end

      Category.set_callback(:save, :after, :enforce_positioning)
    end

    # Returns list of ancestors, starting from parent until root.
    #
    #   subchild1.ancestors # => [child1, root]
    #
    # @return [Array(Category)]
    def ancestors
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end

    # Get products associated with the category.  Optional scope of store.
    #
    # @param store [Store, nil]
    # @return [ActiveRecord::Associations::CollectionProxy(Product)]
    def products(store = nil)
      if store.nil?
        return super
      else
        return Product.joins(:product_categories).where(
            'gemgento_product_categories.store_id = ? AND gemgento_product_categories.category_id = ?',
            store.id,
            self.id
        ).order('gemgento_product_categories.position ASC')
      end
    end

    private

    # Create an associated Category in Magento.
    #
    # @return [Boolean]
    def create_magento_category
      response = API::SOAP::Catalog::Category.create(self, self.stores.first)

      if response.success?
        self.magento_id = response.body[:attribute_id]
        self.sync_needed = false

        self.stores.each_with_index do |store, index|
          next if index == 0
          response = API::SOAP::Catalog::Category.update(self, store)

          # If there was a problem updating on of the stores, then make sure the product will be synced on next save.
          # The product needs to be saved regardless, since a Magento product was created and the id must be set.  So,
          # this will not return false.
          self.sync_needed = true unless response.success?
        end


        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Update associate Magento category.
    #
    # @return [Boolean]
    def update_magento_category
      self.stores.each do |store|
        response = API::SOAP::Catalog::Category.update(self, store)

        unless response.success?
          errors.add(:base, response.body[:faultstring])
          return false
        end
      end

      self.sync_needed = false
      return true
    end

  end
end
