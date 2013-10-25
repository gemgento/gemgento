module Gemgento
  class Subscriber < ActiveRecord::Base
    validates_format_of :email, with: /([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})/
    validates :email, uniqueness: true
  end
end
