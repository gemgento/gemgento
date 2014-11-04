module Gemgento

  # @author Gemgento LLC
	class Page < ActiveRecord::Base
		validates_presence_of :name, :description, :permalink

	end
end