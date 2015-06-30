require 'rails_helper'

RSpec.describe Gemgento::Price do

  describe '#has_special?' do

    before(:each) do
      @user = FactoryGirl.create(:gemgento_user)
      @product = FactoryGirl.create(:gemgento_product_with_attributes)
      @price = Gemgento::Price.new(@product, @user)
    end

    context 'when there is no special price' do
      before { @product.set_attribute_value('special_price', nil) }
      it { expect(@price.has_special?).to be false }
    end

    context 'when there is a special price with no date range' do
      before do
        @product.set_attribute_value('special_price', 10)
        @product.set_attribute_value('special_from_date', nil)
        @product.set_attribute_value('special_to_date', nil)
      end

      it { expect(@price.has_special?).to be true }
    end
  end

end