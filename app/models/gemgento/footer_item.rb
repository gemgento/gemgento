module Gemgento
	class FooterItem < ActiveRecord::Base
		validates_presence_of :name, :url
		validates_numericality_of :position

	end
end