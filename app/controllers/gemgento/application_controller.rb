class Gemgento::ApplicationController < ApplicationController
  include Gemgento::SslRequirement
  layout :set_layout
  before_filter :set_store
end

