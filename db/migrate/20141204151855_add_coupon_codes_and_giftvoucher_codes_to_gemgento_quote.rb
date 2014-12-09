class AddCouponCodesAndGiftvoucherCodesToGemgentoQuote < ActiveRecord::Migration
  def change
    add_column :gemgento_quotes, :coupon_codes, :text
    add_column :gemgento_quotes, :gift_card_codes, :text
  end
end
