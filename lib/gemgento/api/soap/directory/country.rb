module Gemgento
  module API
    module SOAP
      module Directory
        class Country

          # Fetch all Countries from Magento and sync them to Gemgento.
          #
          # @return [Void]
          def self.fetch_all
            response = list

            if response.success?
              response.body[:countries][:item].each do |country|
                sync_magento_to_local(country)
              end
            end
          end

          # Get a list of Countries from Magento.
          #
          # @return [Gemgento::MagentoResponse]
          def self.list
            response = MagentoApi.create_call(:directory_country_list)

            if response.success? && !response.body[:countries][:item].is_a?(Array)
              response.body[:countries][:item] = [response.body[:countries][:item]]
            end

            return response
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