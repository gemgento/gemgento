require 'rails_helper'

RSpec.describe Gemgento::Price do

  before(:each) do
    @user = FactoryGirl.create(:gemgento_user)
    @product = FactoryGirl.create(:gemgento_product_with_attributes)
    @price = Gemgento::Price.new(@product, @user)
  end

  describe '#has_special?' do

    context 'when there is no special price' do
      before { @product.set_attribute_value('special_price', nil) }
      it { expect(@price.has_special?).to be false }
    end

    context 'when there is a special price' do
      before { @product.set_attribute_value('special_price', 10) }

      context 'with no special_form_date and special_to_date' do
        before do
          @product.set_attribute_value('special_from_date', nil)
          @product.set_attribute_value('special_to_date', nil)
        end

        it { expect(@price.has_special?).to be true }
      end

      context 'with only a special_to_date' do
        before { @product.set_attribute_value('special_from_date', nil) }

        context 'in the past' do
          before { @product.set_attribute_value('special_to_date', Date.yesterday.strftime('%F')) }
          it { expect(@price.has_special?).to be false }
        end

        context 'in the present' do
          before { @product.set_attribute_value('special_to_date', Date.today.strftime('%F')) }
          it { expect(@price.has_special?).to be true }
        end

        context 'in the future' do
          before { @product.set_attribute_value('special_to_date', Date.tomorrow.strftime('%F')) }
          it { expect(@price.has_special?).to be true }
        end
      end

      context 'with only a special_from_date' do
        before { @product.set_attribute_value('special_to_date', nil) }

        context 'in the past' do
          before { @product.set_attribute_value('special_from_date', Date.yesterday.strftime('%F')) }
          it { expect(@price.has_special?).to be true }
        end

        context 'in the present' do
          before { @product.set_attribute_value('special_from_date', Date.today.strftime('%F')) }
          it { expect(@price.has_special?).to be true }
        end

        context 'in the future' do
          before { @product.set_attribute_value('special_from_date', Date.tomorrow.strftime('%F')) }
          it { expect(@price.has_special?).to be false }
        end
      end

      context 'with a special_from_date and a special_to_date range' do
        context 'including today' do
          before do
            @product.set_attribute_value('special_from_date', Date.yesterday.strftime('%F'))
            @product.set_attribute_value('special_to_date', Date.tomorrow.strftime('%F'))
          end

          it { expect(@price.has_special?).to be true }
        end

        context 'excluding today' do
          before do
            @product.set_attribute_value('special_from_date', Date.tomorrow.strftime('%F'))
            @product.set_attribute_value('special_to_date', Date.yesterday.strftime('%F'))
          end

          it { expect(@price.has_special?).to be false }
        end
      end
    end
  end

  describe '#gift_price' do
    before do
      @product.set_attribute_value('gift_price', 10)
      @product.set_attribute_value('gift_value', 5)
    end

    context 'when gift_price_type is "Fixed number"' do
      before { @product.set_attribute_value('gift_price_type', 'Fixed number') }
      it { expect(@price.gift_price).to eq(10) }
      end

    context 'when gift_price_type is "Percent of Gift Card value"' do
      before { @product.set_attribute_value('gift_price_type', 'Percent of Gift Card value') }
      it { expect(@price.gift_price).to eq(0.5) }
    end

    context 'when gift_price_type is unknown' do
      before { @product.set_attribute_value('gift_price_type', 'random') }
      it { expect(@price.gift_price).to eq(5) }
    end
  end

  describe '#calculate' do

    context 'when product is a giftvoucher' do
      before do
        @product.update(magento_type: 'giftvoucher')
        @product.set_attribute_value('gift_price', 10)
        @product.set_attribute_value('gift_value', 5)
      end

      it 'returns gift_price' do
        expect(@price.calculate).to eq(5)
      end
    end

    context 'when product is not a giftvoucher' do
      before do
        @product.set_attribute_value('price', 100)
        @product.set_attribute_value('special_price', 75)
        @product.set_attribute_value('special_from_date', nil)
        @product.set_attribute_value('special_to_date', nil)
        FactoryGirl.create(:gemgento_price_tier, quantity: 10, price: 50, product: @product, store: @product.stores.first)
      end

      context 'when original product price is cheapest' do
        before { @product.set_attribute_value('price', 10) }
        it { expect(@price.calculate).to eq(10) }
      end

      context 'when special price is cheapest' do
        before { @product.set_attribute_value('special_price', 75) }
        it { expect(@price.calculate).to eq(75) }
      end

      context 'when PriceTier is cheapest' do
        before { @price.quantity = 11 }
        it { expect(@price.calculate).to eq(50) }
      end
    end
  end

end