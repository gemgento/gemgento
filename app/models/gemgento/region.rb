module Gemgento
  class Region < ActiveRecord::Base
    belongs_to :country

    def self.index
      if Region.find(:all).size == 0
        fetch_all
      end

      Region.find(:all)
    end

    def self.fetch_all
      Country.find(:all).each do |country|
        message = {
            country: country.iso2_code
        }
        response = Gemgento::Magento.create_call(:directory_region_list, message)

        if !response[:countries][:item].nil?
          unless response[:countries][:item].is_a? Array
            response[:countries][:item] = [response[:countries][:item]]
          end

          response[:countries][:item].each do |region|
            sync_magento_to_local(region, country)
          end
        end
      end
    end

    private

    # Save Magento product attribute set to local
    def self.sync_magento_to_local(source, country)
      region = Region.find_or_initialize_by(magento_id: source[:region_id])
      region.magento_id = source[:region_id]
      region.code = source[:code]
      region.name = source[:name]
      region.country = country
      region.save
    end
  end
end