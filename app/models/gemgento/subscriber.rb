module Gemgento
  class Subscriber < ActiveRecord::Base
    belongs_to :country

    validates_format_of :email, with: /([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})/
    validates_presence_of :email
    validates :email, uniqueness: true

    def self.add_user(user)
      subscriber = Gemgento::Subscriber.new
      subscriber.email = user.email
      subscriber.first_name = user.first_name
      subscriber.last_name = user.last_name
      subscriber.save
    end
  end
end
