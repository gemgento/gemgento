module Gemgento
  class User::WishlistItemsController < User::BaseController
    before_filter :authenticate_user!

    def index
      @wishlist_items = current_user.wishlist_items
      respond_with @wishlist_items
    end

    def create
      @wishlist_item = current_user.wishlist_items.create(product_id: params[:product_id])

      respond_to do |format|
        if @wishlist_item.save
          format.html {redirect_to user_wishlist_path, notice: "Item sucessfully added to wishlist."}
          format.json { render json: {result: true, wishlist_item: @wishlist_item} }
        else
          format.html { render 'index', notice: "We were unable to add the item to your wishlist." }
          format.json { render json: { result: false, errors: @wishlist_item.errors.full_messages} }
        end
      end
    end

    def destroy
      @wishlist_item = WishlistItem.find_by(user_id: current_user.id, product_id: params[:id])

      respond_to do |format|
        if @wishlist_item.destroy!
          format.html {redirect_to "/user/wishlist" , notice: "Wishlist item removed."}
          format.json{ render json: { result: true } }
        else
          format.html {render 'index' }
          format.json{ render json: { result: false, errors: @wishlist_item.errors.full_messages } }
        end
      end
    end
  end
end
