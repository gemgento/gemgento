module Gemgento

  # @author Gemgento LLC
  class Swatch < ActiveRecord::Base
    has_many :products

    has_attached_file :image
  end
end