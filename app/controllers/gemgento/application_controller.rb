class Gemgento::ApplicationController < ApplicationController
  layout :set_layout
  before_filter :set_store
end

