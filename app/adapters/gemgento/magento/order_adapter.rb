module Gemgento
  class Magento::OrderAdapter

    attr_accessor :source

    # @param increment_id [Integer]
    # @return [Gemgento::Magento::Shipment]
    def self.find(increment_id)
      response = Gemgento::API::SOAP::Sales::Order.info(increment_id)

      if response.success?
        source = response.body[:result]

        source[:items] = source[:items][:item].nil? ? [] : source[:items][:item]
        source[:items] = [source[:items]] unless source[:items].is_a? Array

        source[:status_history] = source[:status_history][:item].nil? ? [] : source[:status_history][:item]
        source[:status_history] = [source[:status_history]] unless source[:status_history].is_a? Array

        return new(source)
      else
        raise response.body[:faultstring]
      end
    end

    # @param source [Hash]
    def initialize(source)
      Rails.logger.debug 'Gemgento::Magento::OrderAdapter.new:'
      Rails.logger.debug source
      @source = source
    end

    def import
      return nil if ::Gemgento::Store.find_by(magento_id: self.source[:store_id]).nil?

      retry_count ||= 0

      order = ::Gemgento::Order.find_or_initialize_by(increment_id: self.source[:increment_id])
      order.magento_id = self.source[:order_id]
      order.user = ::Gemgento::User.find_by(magento_id: self.source[:customer_id])
      order.quote = ::Gemgento::Quote.find_by(magento_id: self.source[:quote_id])
      order.user_group = ::Gemgento::UserGroup.where(magento_id: self.source[:customer_group_id]).first
      order.store = ::Gemgento::Store.find_by(magento_id: self.source[:store_id])

      source.each do |k, v|
        next if [:store_id, :quote_id].include?(k) || !Gemgento::Order.column_names.include?(k.to_s)
        order.assign_attributes k => v
      end

      order.save!

      Gemgento::Magento::AddressAdapter.new(self.source[:shipping_address], order).import
      Gemgento::Magento::AddressAdapter.new(self.source[:billing_address], order).import
      Gemgento::Magento::PaymentAdapter.new(self.source[:payment], order).import

      # import order statuses
      self.source[:status_history].each do |status|
        Gemgento::Magento::OrderStatusAdapter.new(status, order).import
      end

      # import shipment items
      self.source[:items].each do |item|
        Gemgento::Magento::LineItemAdapter.new(item, order).import
      end
      
      destroy_old_line_items(order)

      order.reload
      return order

    # try one more time to create the record, duplicate record errors are common with threads
    rescue ActiveRecord::RecordInvalid => e
      (retry_count += 1) <= 1 ? retry : raise(e)

    rescue ActiveRecord::RecordNotUnique => e
      (retry_count += 1) <= 1 ? retry : raise(e)
    end

    # Destroy all line items related to the order whose magento_id is not in the source.
    #
    # @param order [Gemgento::Order]
    # @return [void]
    def destroy_old_line_items(order)
      known_ids = self.source[:items].map { |i| i[:item_id] }
      Gemgento::LineItem
          .where(itemizable: order)
          .where.not(magento_id: known_ids)
          .destroy_all
    end

  end
end