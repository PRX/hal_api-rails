require 'forwardable'
require 'openssl'
require 'active_model'
require 'ostruct'

class HalApi::PagedCollection
  extend ActiveModel::Naming
  extend Forwardable

  attr_accessor :items, :request, :options, :facets

  def_delegators :items, :total_count, :prev_page, :next_page, :total_pages, :first_page?, :last_page?
  alias_method :total, :total_count

  def_delegators :request, :params

  class_attribute :representer_class

  def self.representer
    representer_class || HalApi::PagedCollectionRepresenter
  end

  def to_model
    self
  end

  def persisted?
    false
  end

  def initialize(items, request=nil, options=nil)
    self.items   = items
    self.request = request || request_stub
    self.options = options || {}
    self.options[:is_root_resource] = true unless (self.options[:is_root_resource] == false)
  end

  def cache_key
    item_keys = items.inject([]) do |keys, i|
      keys << i.try(:id)
      keys << i.try(:updated_at).try(:utc).to_i
    end
    key_components = ['c', item_class.model_name.cache_key]
    key_components << OpenSSL::Digest::MD5.hexdigest(item_keys.join)
    ActiveSupport::Cache.expand_cache_key(key_components)
  end

  def request_stub
    OpenStruct.new(params: {})
  end

  def is_root_resource
    !!self.options[:is_root_resource]
  end

  def show_curies
    is_root_resource && !options[:no_curies]
  end

  def item_class
    options[:item_class] || self.items.first.try(:item_class) || self.items.first.class
  end

  def item_decorator
    options[:item_decorator] || "Api::#{item_class.name}Representer".constantize
  end

  # url to use for the self:href, can be a string or proc
  def url
    options[:url]
  end

  # If this is an embedded collection, the parent will be set here for use in urls
  def parent
    rep = options[:parent]
    return rep unless rep.respond_to?(:becomes, true)

    klass = rep.class.try(:base_class)
    klass && (klass != rep.class) ? rep.becomes(klass) : rep
  end

  def count
    items.length
  end
end
