module Gemgento
  module API
    module SOAP
      module Directory
        class Country

          def self.fetch_all
            list.each do |country|
              sync_magento_to_local(country)
            end

          end

          def self.list
            response = Gemgento::Magento.create_call(:directory_country_list)

            unless response[:countries][:item].is_a? Array
              response[:countries][:item] = [response[:countries][:item]]
            end

            response[:countries][:item]
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source)
            country = Gemgento::Country.find_or_initialize_by(magento_id: source[:country_id])
            country.magento_id = source[:country_id]
            country.iso2_code = source[:iso2_code]
            country.iso3_code = source[:iso3_code]
            country.name = source[:name]
            country.save
          end

        end
      end
    end
  end
end