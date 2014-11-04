module Gemgento

  # @author Gemgento LLC
  class Subscriber < ActiveRecord::Base
    belongs_to :country

    validates_format_of :email, with: /([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})/
    validates_presence_of :email
    validates :email, uniqueness: true

    def self.manage(user, subscribe)
      if subscribe
        add_user user
      else
        remove_user user
      end
    end

    def self.add_user(user)
      subscriber = Subscriber.find_or_initialize_by(email: user.email)
      subscriber.first_name = user.first_name
      subscriber.last_name = user.last_name
      subscriber.save
    end

    def self.remove_user(user)
      Subscriber.where(email: user.email).destroy_all
    end
  end
end
