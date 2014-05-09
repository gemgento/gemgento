module Gemgento
  class HeartBeat
    include Sidekiq::Worker

    def perform
      require 'net/http'
      require 'uri'

      uri = URI.parse('http://www.gemgento.com/heart_beats')
      Net::HTTP.post_form(uri, {'heart_beat[license_key]' => Gemgento::Config[:license_key]})
    end
  end
end