module Gemgento
	class Page < ActiveRecord::Base
		validates_presence_of :name, :description, :permalink

	end
end