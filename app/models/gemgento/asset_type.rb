module Gemgento
  class AssetType < ActiveRecord::Base
    belongs_to :product_attribute_set
    has_and_belongs_to_many :assets, join_table: 'gemgento_assets_asset_types'
  end
end