module Gemgento
  module API
    module SOAP
      module Directory
        class Region

          def self.fetch_all
            Gemgento::Country.find(:all).each do |country|
              list(country.iso2_code).each do |region|
                sync_magento_to_local(region, country)
              end
            end
          end

          def self.list(country)
            response = Gemgento::Magento.create_call(:directory_region_list, { country: country })

            if !response[:countries][:item].nil?
              unless response[:countries][:item].is_a? Array
                response[:countries][:item] = [response[:countries][:item]]
              end
            else
              response[:countries][:item] = []
            end

            response[:countries][:item]
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source, country)
            region = Gemgento::Region.find_or_initialize_by(magento_id: source[:region_id])
            region.magento_id = source[:region_id]
            region.code = source[:code]
            region.name = source[:name]
            region.country = country
            region.save
          end

        end
      end
    end
  end
end