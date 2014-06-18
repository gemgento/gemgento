module Gemgento
  class Magento::ProductsController < MagentoController

    def new
      @product = Product.new
    end

    def update
      data = params[:data]

      @product = Gemgento::Product.not_deleted.where('id = ? OR magento_id = ?', params[:id], data[:product_id]).first_or_initialize
      @product.magento_id = data[:product_id]
      @product.magento_type = data[:type]
      @product.sku = data[:sku]
      @product.sync_needed = false
      @product.product_attribute_set = Gemgento::ProductAttributeSet.where(magento_id: data[:set]).first
      @product.magento_type = data[:type]
      @product.save

      set_stores(data[:stores], @product) unless data[:stores].nil?

      unless data[:additional_attributes].nil?
        set_assets(data[:additional_attributes], @product)
        set_attribute_values_from_magento(data[:additional_attributes], @product)
      end

      set_associated_products(data[:simple_product_ids], data[:configurable_product_ids], @product)

      render nothing: true
    end

    def destroy
      data = params[:data]

      if Gemgento::Product.not_deleted.where('id = ? OR magento_id = ?', params[:id], data[:product_id]).count > 0
        @product = Gemgento::Product.find_by('id = ? OR magento_id = ?', params[:id], data[:product_id]).mark_deleted!
      end

      render nothing: true
    end

    private

    def set_stores(magento_stores, product)
      product.stores.clear

      magento_stores.each do |magento_id|
        product.stores << Gemgento::Store.find_by(magento_id: magento_id)
      end

      product.save
    end

    def set_attribute_values_from_magento(magento_attribute_values, product)
      magento_attribute_values.each do |store_id, attribute_values|
        store = Gemgento::Store.find_by(magento_id: store_id)

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
          category = Gemgento::Category.find_by(magento_id: magento_category)
          next if category.nil? # deleted categories are still returned from Magento, just skip

          product_category = Gemgento::ProductCategory.find_or_initialize_by(category: category, product: product, store: store)
          product_category.save

          category_ids << category.id
        end
      end

      # remove Product Category relations that were not pushed
      Gemgento::ProductCategory.where('store_id = ? AND product_id = ? AND category_id NOT IN (?)', store.id, product.id, category_ids).destroy_all

      product.save
    end

    def set_assets(magento_source_assets, product)
      assets_to_keep = []

      magento_source_assets.each do |store_id, source_assets| # cycle through media galleries for each

        if !source_assets[:media_gallery].nil? && !source_assets[:media_gallery][:images].nil?
          store = Gemgento::Store.find_by(magento_id: store_id)
          media_gallery = source_assets[:media_gallery][:images]

          media_gallery.each do |source| # cycle through the store specific assets
            asset = Gemgento::Asset.find_or_initialize_by(product_id: product.id, file: source[:file], store: store)

            if !source[:removed].nil? && source[:removed] == 1
              asset.destroy
            else
              url, file = get_url_and_file(source)
              next unless Gemgento::AssetFile.valid_url(url)

              asset.url = url
              asset.position = source[:position]
              asset.label = source[:label]
              asset.product = product
              asset.sync_needed = false
              asset.set_file(URI.parse(url))
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
      Gemgento::Asset.skip_callback(:destroy, :before, :delete_magento)
      product.assets.where('gemgento_assets.id NOT IN (?)', assets_to_keep).destroy_all
      Gemgento::Asset.set_callback(:destroy, :before, :delete_magento)
    end

    def set_associated_products(simple_magento_product_ids, configurable_magento_product_ids, product)
      unless simple_magento_product_ids.nil?
        product.set_simple_products_by_magento_ids(simple_magento_product_ids)
      end

      unless configurable_magento_product_ids.nil?
        product.set_configurable_products_by_magento_ids(configurable_magento_product_ids)
      end
    end

    def get_url_and_file(source)
      if source[:new_file].nil?
        url = "http://#{Gemgento::Config[:magento][:url]}/media/catalog/product#{source[:file]}"
        file = source[:file]
      else
        url = "http://#{Gemgento::Config[:magento][:url]}/media/catalog/product#{source[:new_file]}"
        file = source[:new_file]
      end

      return url, file
    end

  end
end