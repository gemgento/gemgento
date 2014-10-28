module Gemgento
  class OrderExportController < ApplicationController

    def index
      raise 'No order attributes requested' if params[:order_attributes].nil?
      raise 'No order item product attributes requested' if params[:line_item_product_attributes].nil?
      raise 'No order item attributes requested' if params[:line_item_attributes].nil?

      @order_export = OrderExport.new(
          params[:start_datetime].nil? ? (Time.now - 1.day).to_datetime : params[:start_datetime].to_datetime,
          params[:order_attributes].split(','),
          params[:line_item_product_attributes].split(','),
          params[:line_item_attributes].split(','),
          params[:delimiter].nil? ? ',' : params[:delimiter],
          params[:path]
      )
      @order_export.generate
      render @order_export.export_csv
    end
  end
end