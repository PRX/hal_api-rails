# encoding: utf-8

module HalApi::RepresentedModel
  extend ActiveSupport::Concern

  # this concept is used in result set, perhaps doesn't belong in model itself
  # consider if there is a better way to do this - decorate model instead?
  attr_accessor :is_root_resource

  def is_root_resource
    !!@is_root_resource
  end

  def show_curies
    is_root_resource
  end

  def id_from_url(url)
    Rails.application.routes.recognize_path(url)[:id]
  end

  included do
    extend ActiveModel::Naming unless (method(:model_name) rescue nil)
  end
end
