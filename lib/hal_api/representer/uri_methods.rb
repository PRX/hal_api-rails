require "active_support/concern"

# expects underlying model to have filename, class, and id attributes
module HalApi::Representer::UriMethods
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :profile_host, :alternate_host
    end
  end

  module ClassMethods
    def self_link
      link(:self) do
        {
          href: self_url(represented),
          profile: profile_url(represented)
        }
      end
    end

    def vary_link
      link(:vary) do
        if vary_url(represented).present? && vary_params.present?
          {
            href: vary_url(represented) + vary_query_params,
            templated: true
          }
        end
      end
    end

    def profile_link
      link(:profile) { profile_url(represented) }
    end

    def alternate_link
      link :alternate do
        {
          href: alternate_url(model_path(represented)),
          type: "text/html"
        }
      end
    end
  end

  def model_path(represented)
    rep = becomes_represented_class(represented)
    class_path = rep.class.name.underscore.pluralize
    "#{class_path}/#{represented.id}"
  end

  def self_url(represented)
    rep = becomes_represented_class(represented)
    polymorphic_path([:api, rep])
  end

  def vary_url(represented)
    self_url(represented)
  end

  def vary_params
    []
  end

  def vary_query_params
    "{?#{vary_params.join(",")}}"
  end

  def becomes_represented_class(rep)
    return rep unless rep.respond_to?(:becomes, true)

    klass = rep.try(:item_class) || rep.class.try(:base_class)
    (klass && (klass != rep.class)) ? rep.becomes(klass) : rep
  end

  def alternate_url(*path)
    "https://#{self.class.alternate_host}/#{path.map(&:to_s).join("/")}"
  end

  def model_uri(*args)
    "http://#{self.class.profile_host}/model/#{joined_names(args)}"
  end

  alias_method :profile_url, :model_uri

  def joined_names(args)
    (Array(args.map { |arg| model_uri_part_to_string(arg) }) +
      model_uri_suffix(args)).flatten.compact.join("/")
  end

  def model_uri_suffix(args)
    represented = args.last
    klass = represented.try(:item_decorator) || self.class
    find_model_name(klass).deconstantize.underscore.dasherize.split("/")[1..-1] || []
  end

  def find_model_name(klass)
    klass.try(:name) || klass.ancestors.detect { |c| c.try(:name) }.name
  end

  def model_uri_part_to_string(part)
    if part.is_a?(String) || part.is_a?(Symbol)
      part.to_s.dasherize
    else
      klass = part.is_a?(Class) ? part : (part.try(:item_class) || part.class)
      if klass.respond_to?(:base_class, true) && !klass.superclass.name.demodulize.starts_with?("Base")
        parent = klass.superclass.name.underscore.dasherize
        child = klass.name.underscore.gsub(/_#{parent}$/, "").dasherize
        [parent, child]
      else
        klass.name.underscore.dasherize
      end
    end
  end

  def method_missing(method_name, *, &block)
    if method_name.to_s.ends_with?("_path_template")
      original_method_name = method_name[0..-10]
      template_named_path(original_method_name, *)
    else
      super(method_name, *args, &block)
    end
  end

  def template_named_path(named_path, options)
    replace_options = options.keys.each_with_object({}) do |k, s|
      s[k] = "_#{k.upcase}_REPLACE_"
    end
    path = send(named_path, replace_options)
    replace_options.keys.each do |k|
      path.gsub!(replace_options[k], (options[k] || ""))
    end
    path
  end
end
