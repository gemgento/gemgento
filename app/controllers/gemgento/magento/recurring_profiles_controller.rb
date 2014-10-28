module Gemgento
  class Magento::RecurringProfilesController < MagentoController

    def update
      data = params[:data]

      profile = Gemgento::RecurringProfile.find_or_initialize_by(magento_id: params[:id])
      profile.state = data['state']
      profile.store = Gemgento::Store.find_by(magento_id: data['store_id'])
      profile.method_code = data['method_code']
      profile.reference_id = data['reference_id']
      profile.subscriber_name = data['subscriber_name']
      profile.start_datetime = data['start_datetime'].to_datetime
      profile.internal_reference_id = data['internal_reference_id']
      profile.schedule_description = data['schedule_description']
      profile.period_unit = data['period_unit']
      profile.period_frequency = data['period_frequency']
      profile.billing_amount = data['billing_amount']
      profile.currency_code = data['currency_code']
      profile.shipping_amount = data['shipping_amount']
      profile.tax_amount = data['tax_amount']
      profile.order_info = data['order_info']
      profile.line_item_info = data['line_item_info']
      profile.billing_address_info = data['billing_address_info']
      profile.shipping_address_info = data['shipping_address_info']
      profile.profile_vendor_info = data['profile_vendor_info']
      profile.additional_info = data['additional_info']

      if user = Gemgento::User.find_by(magento_id: data['customer_id'])
        profile.user = user
      end

      profile.save
      profile.orders = Gemgento::Order.where(order_id: data['order_ids'])

      render nothing: true
    end

  end
end