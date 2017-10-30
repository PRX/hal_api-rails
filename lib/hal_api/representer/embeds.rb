require 'active_support/concern'
require 'hal_api/paged_collection'

# expects underlying model to have filename, class, and id attributes
module HalApi::Representer::Embeds
  extend ActiveSupport::Concern

  included do
    Representable::Mapper.send(:include, Resources) if !Representable::Mapper.include?(Resources)
  end

  def normalize_options!(options)
    propagated_options, private_options = super(options)

    # we want this to propogate, and be available for `skip_property?`, so don't delete
    private_options[:zoom] = options[:zoom] if options.key?(:zoom)

    [propagated_options, private_options]
  end

  module Resources

    def skip_property?(binding, private_options)
      super(binding, private_options) || suppress_embed?(binding, private_options)
    end

    # embed if zoomed
    def suppress_embed?(binding, options)
      name = binding[:as].evaluate(self).to_s || binding.name
      embedded = !!binding[:embedded]

      # not embedded, return false - nothing to suppress
      return false if !embedded

      # check if it should be zoomed, suppress if not
      !embed_zoomed?(name, binding[:zoom], options[:zoom])
    end

    def embed_zoomed?(name, zoom_def = nil, zoom_param = nil)
      # if the embed in the representer definition has `zoom: :always` defined
      # always embed it, even if it is in another embed
      # (this is really meant for collections where embedded items must be included)
      return true if zoom_def == :always

      # passing nil explicitly overwrites defaults in signature,
      # so we default to nil and fix in the method body
      zoom_def = true if zoom_def.nil?

      # if there is no zoom specified in the request params (options)
      # then embed based on the zoom option in the representer definition

      # if there is a zoom specified in the request params (options)
      # then do not zoom when this name is not in the request
      zoom_param.nil? ? zoom_def : zoom_param.include?(name)
    end
  end

  # Possible values for zoom option in the embed representer definition
  # * false - will be zoomed only if in the root doc and in the zoom param
  # * true - zoomed in root doc if no zoom_param, or if included in zoom_param
  # * always - zoomed no matter what is in zoom param, and even if in embed
  module ClassMethods

    def embed(name, options={})
      options[:embedded] = true
      options[:writeable] = false
      options[:if] ||= ->(_a) { id } unless options[:zoom] == :always

      if options[:paged]
        opts = {
          no_curies: true,
          item_class: options.delete(:item_class),
          url: options.delete(:url),
          item_decorator: options.delete(:item_decorator)
        }
        getter_per = options.delete(:per) || Kaminari.config.default_per_page
        options[:getter] ||= ->(*) do
          cnt = send(name).count
          per = getter_per == :all ? cnt : getter_per
          if cnt <= per
            items = Kaminari.paginate_array(send(name)).page(1).per(per)
          else
            items = send(name).page(1).per(per)
          end
          HalApi::PagedCollection.new(items, nil, opts.merge(parent: self))
        end
        options[:decorator] = HalApi::PagedCollection.representer
      end

      property(name, options)
    end

    def embeds(name, options={})
      options[:embedded] = true
      options[:writeable] = false
      options[:if] ||= ->(_a) { id } unless options[:zoom] == :always

      collection(name, options)
    end
  end
end
