require_dependency 'gemgento/application_controller'

module Gemgento
  class Api::V1::CategoriesController < ApplicationController
    include DeviseTokenAuth::Concerns::SetUserByToken
  end
end
