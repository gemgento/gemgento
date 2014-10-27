json.(address, :id, :user_address_id, :user_id, :increment_id, :city, :company, :country_id, :fax, :first_name, :middle_name, :last_name, :postcode, :prefix, :suffix, :region_name, :region_id, :street, :telephone, :address_type, :sync_needed, :created_at, :updated_at, :is_default_billing, :is_default_shipping)
json.address1 address.address1
json.address2 address.address2
json.address3 address.address3
json.country address.country.name unless self.country.nil?
json.region address.region.name unless self.region.nil?