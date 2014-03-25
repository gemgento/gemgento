module Gemgento

  # @author Gemgento LLC
  class AssetFile < ActiveRecord::Base
    has_many :assets
    has_many :products, through: :assets
    has_many :stores, through: :assets

    has_attached_file :file
  end
end