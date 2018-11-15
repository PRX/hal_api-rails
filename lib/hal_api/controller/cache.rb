module HalApi::Controller::Cache
  extend ActiveSupport::Concern

  private

  def index_cache_path
    HalApi::PagedCollection.new(
      filtered(paged(sorted(scoped(resources_base)))),
      request,
      item_class: self.class.resource_class,
      item_decorator: self.class.resource_representer
    ).cache_key
  end

  def current_time
    Datetime.now
  end

  def show_cache_path
    timestamp = show_resource.updated_at || show_resource.created_at
    timestamp = if timestamp.nil?
                  # skip the cache
                  current_time
                else
                  timestamp
                end
    timestamp.utc.to_i
  end

  module ClassMethods
    def cache_api_action(action, options = {})
      options = cache_options.merge(options || {})
      cache_path_method = options.delete(:cache_path_method)
      cache_path_method ||= "#{action}_cache_path"
      unless options[:cache_path]
        options[:cache_path] = lambda do |c|
          c.send(:valid_params_for_action, action).merge _c: send(cache_path_method)
        end
      end
      caches_action(action, options)
    end

    def cache_options
      { compress: true, expires_in: 1.hour, race_condition_ttl: 30 }
    end
  end
end
