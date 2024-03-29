require 'hal_api/representer'

module HalApi::Representer::CollectionPaging
  extend ActiveSupport::Concern

  included do
    class_eval do
      property :count
      property :total
      property :facets

      embeds :items, decorator: lambda{|*| item_decorator }, class: lambda{|*| item_class }, zoom: :always

      link :prev do
        href_url_helper(params.merge(page: represented.prev_page)) if represented.prev_page
      end

      link :next do
        href_url_helper(params.merge(page: represented.next_page)) if represented.next_page
      end

      link :first do
        href_url_helper(params.merge(page: nil)) if represented.total_pages > 1
      end

      link :last do
        href_url_helper(params.merge(page: represented.total_pages)) if represented.total_pages > 1
      end
    end
  end

  def params
    represented.params
  end

  def self_url(represented)
    href_url_helper(represented.params)
  end

  def vary_url(represented)
    href_url_helper(represented.params.except(*vary_params))
  end

  def vary_params
    %w(page per zoom filters sorts)
  end

  def profile_url(represented)
    model_uri(:collection, represented.item_class)
  end

  # refactor to use single property, :url, that can be a method name, a string, or a lambda
  # if it is a method name, execute against self - the representer - which has local url helpers methods
  # if it is a sym/string, but self does not respond to it, then just use that string
  # if it is a lambda, execute in the context against the represented.parent (if there is one) or represented
  def href_url_helper(options={})
    if represented_url.nil?
      options = options.except(:format)
      result = url_for(options.merge(only_path: true)) rescue nil
      if represented.parent
        result ||= polymorphic_path([:api, represented.parent, represented.item_class], options) rescue nil
      end
      result ||= polymorphic_path([:api, represented.item_class], options) rescue nil
      return result
    end

    if represented_url.respond_to?(:call, true)
      instance_exec(options, &represented_url)
    elsif respond_to?(represented_url, true)
      send(represented_url, options)
    else
      represented_url.to_s
    end
  end

  def represented_url
    @represented_url ||= represented.try(:url)
  end
end
