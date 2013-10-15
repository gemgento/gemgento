module Gemgento
  class Asset < ActiveRecord::Base
    belongs_to :product

    has_and_belongs_to_many :asset_types, -> { uniq }, :join_table => 'gemgento_assets_asset_types'

    after_save :sync_local_to_magento
    after_save :touch_product

    before_destroy :delete_magento

    has_attached_file :attachment,
                      :styles => {:mini => '32x32>', :normal => '172x172>'},
                      :default_style => :normal,
                      :url => "/system/assets/products/:id/:style/:filename",
                      :path => ":rails_root/public/system/assets/products/:id/:style/:filename"

    default_scope -> { order(:label) }

    def save
      # Dirty dirty dirty(S3Bug)..
      begin
        super
      rescue Exception => e
        puts "Upload Failed once.."

        begin
          super
        rescue Exception => e
          puts "Upload Failed twice.."

          begin
            super
          rescue Exception => e
            puts "Upload Failed three times.."

            super
          end
        end
      end
    end

    private

    def sync_local_to_magento
      if self.sync_needed
        API::SOAP::Catalog::ProductAttributeMedia.create(self)
        self.sync_needed = false
        self.save
      end
    end

    def delete_magento
      unless self.file.nil?
        API::SOAP::Catalog::ProductAttributeMedia.remove(self)
      end

      self.asset_types.clear
    end

    def touch_product
      self.product.update(updated_at: Time.now) if self.changed?
    end

  end
end