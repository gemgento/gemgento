require 'rails_helper'

RSpec.describe Gemgento::PriceTier, type: :model do

  describe '#is_valid?' do

    let(:price_tier) { FactoryGirl.build(:gemgento_price_tier, quantity: 10, price: 10) }

    context 'when quantity is greater than price tier' do
      it { expect(price_tier.is_valid?(11, nil)).to eq(true) }
    end

    context 'when quantity is less than price tier' do
      it { expect(price_tier.is_valid?(9, nil)).to eq(false) }
    end

    context 'when user group differs from price tier' do
      it { expect(price_tier.is_valid?(9, FactoryGirl.create(:gemgento_user_group))).to eq(false) }
    end

  end

  describe '#calculate_price' do

    let(:product) { FactoryGirl.create(:gemgento_product_with_attributes) }
    let!(:price_tier_1) { FactoryGirl.create(:gemgento_price_tier, quantity: 10, price: 10, product: product) }
    let!(:price_tier_2) { FactoryGirl.create(:gemgento_price_tier, quantity: 5, price: 5, product: product) }

    before { product.set_attribute_value('price', 100) }

    context 'when quantity less then any price tier' do
      it 'returns product price' do
        expect(Gemgento::PriceTier.calculate_price(product)).to eq(100)
      end
    end

    context 'when there are multiple valid price tiers' do
      it 'returns the cheapest price tier' do
        expect(Gemgento::PriceTier.calculate_price(product, 10)).to eq(5)
      end
    end

  end

end