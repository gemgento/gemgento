class Gemgento::ApiUser < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
end
