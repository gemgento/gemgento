module Gemgento
  module Magento
    class ProductsController < Gemgento::Magento::BaseController

      def update
        data = params[:data]

        @product = Gemgento::Product.not_deleted.where('id = ? OR magento_id = ?', params[:id], data[:product_id]).first_or_initialize

        if @product.new_record? || !@product.magento_id.nil?
          @product.magento_id = data[:product_id]
          @product.magento_type = data[:type]
          @product.sku = data[:sku]
          @product.sync_needed = false
          @product.product_attribute_set = ProductAttributeSet.where(magento_id: data[:set]).first
          @product.magento_type = data[:type]
          @product.save

          set_stores(data[:stores], @product) unless data[:stores].nil?

          unless data[:additional_attributes].nil?
            set_assets(data[:additional_attributes], @product)
            set_attribute_values_from_magento(data[:additional_attributes], @product)
          end

          set_associated_products(data[:simple_product_ids], data[:configurable_product_ids], @product)
          set_bundle_options(data[:bundle_options], @product) if data[:bundle_options]
          set_tier_prices(data[:tier_price], @product) if data[:tier_price]
        end

        render nothing: true
      end

      def destroy
        data = params[:data]

        if Product.not_deleted.where('id = ? OR magento_id = ?', params[:id], data[:product_id]).count > 0
          @product = Product.find_by('id = ? OR magento_id = ?', params[:id], data[:product_id]).mark_deleted!
        end

        render nothing: true
      end

      private

      def set_stores(magento_stores, product)
        product.stores.clear

        magento_stores.each do |magento_id|
          product.stores << Store.find_by(magento_id: magento_id)
        end

        product.save
      end

      def set_attribute_values_from_magento(magento_attribute_values, product)
        magento_attribute_values.each do |store_id, attribute_values|
          store = Store.find_by(magento_id: store_id)

          attribute_values.each do |code, value|

            case code.to_s
              when 'visibility'
                product.visibility = value.to_i
                product.save
              when 'status'
                product.status = value.to_i == 1 ? 1 : 0
                product.save
              when 'category_ids'
                set_categories(value, product, store)
              else
                product.set_attribute_value(code, value, store)
            end
          end
        end
      end

      def set_categories(magento_categories, product, store)
        category_ids = []

        # loop through each return category and add it to the product if needed
        unless magento_categories.nil?
          magento_categories.each do |magento_category|
            category = Category.find_by(magento_id: magento_category)
            next if category.nil? # deleted categories are still returned from Magento, just skip

            product_category = ProductCategory.find_or_initialize_by(category: category, product: product, store: store)
            product_category.sync_needed = false
            product_category.save

            category_ids << category.id
          end
        end

        # remove Product Category relations that were not pushed
        ProductCategory.where(store: store, product: product).where.not(category_id: category_ids).destroy_all

        product.save
      end

      def set_assets(magento_source_assets, product)
        assets_to_keep = []

        magento_source_assets.each do |store_id, source_assets| # cycle through media galleries for each

          if !source_assets[:media_gallery].nil? && !source_assets[:media_gallery][:images].nil?
            store = Store.find_by(magento_id: store_id)
            media_gallery = source_assets[:media_gallery][:images]

            media_gallery.each do |source| # cycle through the store specific assets
              asset = Asset.find_or_initialize_by(product_id: product.id, file: source[:file], store: store)

              if !source[:removed].nil? && source[:removed] == 1
                asset.destroy
              else
                url, file = get_url_and_file(source)
                next unless AssetFile.valid_url(url)

                asset.url = url
                asset.position = source[:position]
                asset.label = source[:label]
                asset.product = product
                asset.sync_needed = false
                asset.set_file Gemgento::AssetFile.from_url(url)
                asset.file = file
                asset.store = store
                asset.save

                asset.set_types_by_codes(source[:types]) unless source[:types].nil?
                assets_to_keep << asset.id
              end
            end
          end
        end

        # destroy any assets that were not in the media gallery for each store
        # this is a failsafe for image deletions that were not registered
        Asset.skip_callback(:destroy, :before, :delete_magento)
        product.assets.where('gemgento_assets.id NOT IN (?)', assets_to_keep).destroy_all
        Asset.set_callback(:destroy, :before, :delete_magento)
      end

      def set_associated_products(simple_magento_product_ids, configurable_magento_product_ids, product)
        unless simple_magento_product_ids.nil?
          product.set_simple_products_by_magento_ids(simple_magento_product_ids)
        end

        unless configurable_magento_product_ids.nil?
          product.set_configurable_products_by_magento_ids(configurable_magento_product_ids)
        end
      end

      def set_bundle_options(bundle_options_data, product)
        bundle_options_data.each do |bundle_option_data|
          bundle_option = product.bundle_options.find_or_initialize_by(magento_id: bundle_option_data[:id])
          bundle_option.is_required = bundle_option_data[:required].to_i == 1 ? true : false
          bundle_option.position = bundle_option_data[:position]
          bundle_option.name = bundle_option_data[:default_title]

          bundle_option_data[:type] = 'selection' if bundle_option_data[:type] == 'select'
          bundle_option.input_type = Gemgento::Bundle::Option.input_types[bundle_option_data[:type].to_sym]

          bundle_option.save

          unless bundle_option_data[:selections].nil?
            bundle_option_data[:selections].each do |selection|
              bundle_item = bundle_option.items.find_or_initialize_by(magento_id: selection[:id])
              bundle_item.product = Gemgento::Product.find_by(magento_id: selection[:product_id])
              bundle_item.price_type = selection[:price_type].to_i
              bundle_item.price_value = selection[:price_value].to_f
              bundle_item.default_quantity = selection[:qty].to_f
              bundle_item.is_user_defined_quantity = selection[:can_change_qty].to_i == 1
              bundle_item.position = selection[:position]
              bundle_item.is_default = selection[:is_default].to_i == 1
              bundle_item.save
            end
          end
        end
      end

      def get_url_and_file(source)
        if source[:new_file].nil?
          url = "#{Config[:magento][:url]}/media/catalog/product#{source[:file]}"
          file = source[:file]
        else
          url = "#{Config[:magento][:url]}/media/catalog/product#{source[:new_file]}"
          file = source[:new_file]
        end

        return url, file
      end

      def set_tier_prices(tier_prices, product)
        prices = []


        tier_prices.each do |source|
          next if source[:delete].to_bool

          user_group = Gemgento::UserGroup.find_by(magento_id: source[:cust_group])
          store = Gemgento::Store.find_by(website_id: source[:website_id])
          stores = store.code == 'admin' ? Gemgento::Store.all : [store]

          stores.each do |store|
            prices << product.price_tiers.find_or_create_by(
                user_group: user_group,
                store: store,
                quantity: source[:price_qty],
                price: source[:price]
            )
          end
        end

        # remove unused product price tiers for the store
        product.price_tiers.where.not(id: prices.map(&:id)).destroy_all
      end

    end
  end
end