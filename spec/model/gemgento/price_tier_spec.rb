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

end