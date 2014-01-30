module Gemgento
  class Subscriber < ActiveRecord::Base
    belongs_to :country

    validates_format_of :email, with: /([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})/
    validates_presence_of :email
    validates :email, uniqueness: true
  end
end
