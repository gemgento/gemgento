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
      else
        @category = Gemgento::Category.top_level.navigation.first
      end

      @products = @category.products.active.catalog_visible
    end

    def update
      @category = Gemgento::Category.find(params[:category_id][0])

      Gemgento::Product.unscoped do
        params[:product].each_with_index do |id, index|
          Gemgento::ProductCategory.where(category_id: @category.id, product_id: id).each do |product_category|
            product_category.position = index
            product_category.sync_needed = product_category.changed?
            product_category.save
          end
        end
      end

      render nothing: true
    end
  end
end
