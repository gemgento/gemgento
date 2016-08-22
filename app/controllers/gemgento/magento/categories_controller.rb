module Gemgento
  module Magento
    class CategoriesController < Gemgento::Magento::BaseController

      def update
        @category = Category.find_or_initialize_by(magento_id: params[:id])
        data = params[:data]

        @category.magento_id = data[:category_id]
        @category.is_active = data[:is_active].to_i == 1 ? true : false
        @category.position = data[:position]
        @category.parent = Category.find_by(magento_id: data[:parent_id]) unless data[:parent_id].nil?
        @category.name = data[:name]
        @category.url_key = data[:url_key]
        @category.include_in_menu = data[:include_in_menu]
        @category.sync_needed = false

        if data.key? :image
          begin
            @category.image = magento_image(data[:image][:value])
          rescue
            @category.image = nil
          end
        end

        @category.save

        set_stores(data[:store_ids], @category)
        set_products(data[:products], @category) unless data[:products].nil?
        fail
        render nothing: true
      end

      def destroy
        @category = Category.find_by(magento_id: params[:id])

        unless @category.nil?
          @category.children.each do |category|
            category.mark_deleted!
          end

          @category.mark_deleted!
        end

        render nothing: true
      end

      private

      def set_stores(magento_store_ids, category)
        category.stores.clear

        magento_store_ids.each do |magento_id|
          next if magento_id.to_i == 0 # 0 is the admin store which is not used in Gemgento
          category.stores << Store.find_by(magento_id: magento_id)
        end

        category.save
      end

      def set_products(stores_products, category)
        stores_products.each do |store_id, products|
          next if store_id.to_i == 0 # 0 is the admin store which is not used in Gemgento
          store = Store.find_by(magento_id: store_id)

          if products.nil?
            ProductCategory.where(store_id: store.id, category_id: category.id).destroy_all
          else
            product_category_ids = []
            product_ids = products.map { |p| p[:product_id] }
            ProductCategory.where(store: store, category: category).delete_all

            Product.where(magento_id: product_ids).each do |product|
              pairing = ProductCategory.find_or_initialize_by(category: category, product: product, store: store)
              item = products.select { |p| p[:product_id].to_i == product.magento_id }.first
              pairing.position = item[:position].is_a?(Array) ? item[:position].first : item[:position]
              pairing.store = store
              pairing.sync_needed = false
              pairing.save!

              product_category_ids << pairing.id
            end

            ProductCategory.where(store: store, category: category).where.not(id: product_category_ids).destroy_all
          end
        end
      end

      def magento_image(file_name)
        url = "#{Gemgento::Config[:magento][:url]}/media/catalog/category/#{file_name}"

        if Gemgento::Config[:magento][:auth_username].blank?
          open(url)
        else
          open(url,
               http_basic_authentication:
                   [ Gemgento::Config[:magento][:auth_username], Gemgento::Config[:magento][:auth_password] ]
               )
        end
      end

    end
  end
end
