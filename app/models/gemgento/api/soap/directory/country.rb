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

            if response.success?
              unless response.body[:countries][:item].is_a? Array
                response.body[:countries][:item] = [response.body[:countries][:item]]
              end

              response.body[:countries][:item]
            end
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source)
            country = Gemgento::Country.where(magento_id: source[:country_id]).first_or_initialize
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