module Gemgento
  class UserGroup < ActiveRecord::Base
    def self.index
      if UserGroup.find(:all).size == 0
        fetch_all
      end

      UserGroup.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:customer_group_list)

      if response[:result][:item].is_a? Array
        response[:result][:item].each do |customer_group|
          sync_magento_to_local(customer_group)
        end
      else
        sync_magento_to_local(response[:result][:item])
      end

    end

    private

    # Save Magento product attribute set to local
    def self.sync_magento_to_local(source)
      customer_group = UserGroup.find_or_initialize_by(magento_id: source[:customer_group_id])
      customer_group.magento_id = source[:customer_group_id]
      customer_group.code = source[:customer_group_code]
      customer_group.save
    end
  end
end