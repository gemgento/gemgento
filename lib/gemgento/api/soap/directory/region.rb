module Gemgento
  module API
    module SOAP
      module Directory
        class Region

          def self.fetch_all
            ::Gemgento::Country.all.each do |country|
              list(country.iso2_code).each do |region|
                sync_magento_to_local(region, country)
              end
            end
          end

          def self.list(country)
            response = Magento.create_call(:directory_region_list, {country: country})

            if response.success?
              if !response.body[:countries][:item].nil?
                unless response.body[:countries][:item].is_a? Array
                  response.body[:countries][:item] = [response.body[:countries][:item]]
                end
              else
                response.body[:countries][:item] = []
              end

              response.body[:countries][:item]
            end
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source, country)
            region = Gemgento::Region.where(magento_id: source[:region_id]).first_or_initialize
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