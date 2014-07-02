ActiveAdmin.register_page 'Product Positions' do
  menu parent: 'Gemgento', priority: 7

  page_action :update, method: :post

  action_item do
    link_to 'Save Positions', admin_product_positions_update_path, method: :post, id: 'submit-product-positions'
  end

  content do
    render 'index'
  end

  controller do
    def index      
      if params[:category_id]
        @category = Gemgento::Category.find(params[:category_id])
      elsif Gemgento::Category.top_level.navigation.any?
        @category = Gemgento::Category.top_level.navigation.first
      else
        @category = Gemgento::Category.root
      end

      @store = params[:store_id].blank? ? nil : Gemgento::Store.find(params[:store_id])
      @products = @category.products(@store).active.catalog_visible
    end

    def update
      @category = Gemgento::Category.where(id: params[:category_id]).first
      @stores = params[:store_id].blank? ? Gemgento::Store.all : Gemgento::Store.where(id: params[:store_id])

      @stores.each do |store|
        params[:products].split(',').each_with_index do |id, index|
          product_category = Gemgento::ProductCategory.find_or_initialize_by(category_id: @category.id, product_id: id, store_id: store.id)
          product_category.position = index
          product_category.sync_needed = false
          product_category.save
        end

        Gemgento::API::SOAP::Catalog::Category.update_product_positions(@category, store)
      end

      flash[:notice] = 'Product positions successfully updated.'
      redirect_to admin_product_positions_path(category_id: @category.id, store_id: params[:store_id])
    end
  end
end
