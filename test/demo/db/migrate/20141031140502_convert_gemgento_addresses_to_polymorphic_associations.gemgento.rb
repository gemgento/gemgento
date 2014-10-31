# This migration comes from gemgento (originally 20141029160052)
# This migration comes from gemgento (originally 20141029160052)
class ConvertGemgentoAddressesToPolymorphicAssociations < ActiveRecord::Migration
  def up
    Gemgento::Address.skip_callback(:update, :before, :update_magento_address)
    Gemgento::Address.skip_callback(:save, :after, :enforce_single_default)

    Gemgento::Address.all.find_each do |address|

      if !address.order_id.blank? && !address.address_type.blank?

        if order = Gemgento::Order.find_by(id: address.order_id)

          if address.address_type == 'shipping'
            address.is_shipping = true
            address.is_billing = false

          elsif address.address_type == 'billing'
            address.is_shipping = false
            address.is_billing = true
          end

          address.addressable = order
          address.sync_needed = false
          address.save validate: false
        end

      elsif user = Gemgento::User.find_by(id: address.user_id)
        address.addressable = user
        address.sync_needed = false
        address.save validate: false
      end
    end

    Gemgento::Address.set_callback(:update, :before, :update_magento_address)
    Gemgento::Address.set_callback(:save, :after, :enforce_single_default)
  end

  def down
    Gemgento::Address.skip_callback(:update, :before, :update_magento_address)
    Gemgento::Address.skip_callback(:save, :after, :enforce_single_default)

    Gemgento::Address.where('addressable_type IS NOT NULL').find_each do |address|

      if address.addressable_type == 'Gemgento::Order'
        order = address.addressable

        if address.is_shipping
          address.address_type = 'shipping'
          order.shipping_address_id = address.addressable_id
        elsif address.is_billing
          address.address_type = 'billing'
          order.billing_address_id = address.addressable_id
        end

        order.save validate: false

      elsif address.addressable_type = 'Gemgento::User'
        address.user_id = address.addressable_id
        address.sync_needed = false
        address.save validate: false
      end
    end

    Gemgento::Address.set_callback(:update, :before, :update_magento_address)
    Gemgento::Address.set_callback(:save, :after, :enforce_single_default)
  end

end
