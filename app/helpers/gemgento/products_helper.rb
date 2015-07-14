module Gemgento
  module ProductsHelper

    def next_product
      @next_product ||= begin
        current_index = current_category_products.index(@product)
        current_index < current_category_products.length ? current_category_products[current_index + 1] : nil
      end
    end

    def previous_product
      @previous_product ||= begin
        current_index = current_category_products.index(@product)
        current_index > 0 ? current_category_products[current_index - 1] : nil
      end
    end

    def current_category_products
      @current_category_product_ids ||= @product.current_category.products.active.catalog_visible.to_a
    end

  end
end