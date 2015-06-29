RSpec.describe Gemgento::PriceTier, type: :model do

  describe 'is_valid?' do

    let(:price_tier) { FactoryGirl.create(:gemgento_price_tier, quantity: 10, user_group: nil) }

    it 'returns true when over quantity and matching user group' do
      expect(price_tier.is_valid?(11, nil)).to eq(true)
    end

    it 'returns false when under quantity' do
      expect(price_tier.is_valid?(9, nil)).to eq(false)
    end

    it 'returns false when user group does not match' do
      price_tier.update(user_group: FactoryGirl.create(:gemgento_user_group))
      expect(price_tier.is_valid?(9, nil)).to eq(false)
    end

  end

  describe 'calculate_price' do

    let!(:product) { FactoryGirl.create(:gemgento_product_with_attributes) }
    let!(:price_tier_1) { FactoryGirl.create(:gemgento_price_tier, quantity: 10, price: 10, product: product, store: product.stores.first!) }
    let!(:price_tier_2) { FactoryGirl.create(:gemgento_price_tier, quantity: 5, price: 5, product: product, store: product.stores.first!) }

    it 'returns product price if no valid price tier' do
      expect(Gemgento::PriceTier.calculate_price(product)).to eq(product.attribute_value('price').to_f)
    end

    it 'returns only the valid tier price' do
      expect(Gemgento::PriceTier.calculate_price(product, 5)).to eq(5)
    end

    it 'returns the cheapest price tier' do
      expect(Gemgento::PriceTier.calculate_price(product, 10)).to eq(5)
    end

  end

end