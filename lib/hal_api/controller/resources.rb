module HalApi::Controller::Resources
  extend ActiveSupport::Concern

  private

  # action specific resources

  def index_collection
    HalApi::PagedCollection.new(
      resources,
      request,
      item_class: self.class.resource_class,
      item_decorator: self.class.resource_representer
    )
  end

  def show_resource
    resource
  rescue ::ActiveRecord::RecordNotFound
    raise HalApi::Errors::NotFound.new
  end

  def update_resource
    resource
  rescue ::ActiveRecord::RecordNotFound
    raise HalApi::Errors::NotFound.new
  end

  def create_resource
    resource
  end

  def destroy_resource
    resource
  rescue ::ActiveRecord::RecordNotFound
    raise HalApi::Errors::NotFound.new
  end

  def resource
    resource = instance_variable_get(:"@#{resource_name}")
    return resource if resource

    resource = if params[:id]
      find_base.send(self.class.find_method, params[:id])
    elsif request.post?
      filtered(resources_base).build
    end
    raise HalApi::Errors::NotFound.new if resource.nil?
    self.resource = resource
  end

  def resource=(res)
    instance_variable_set(:"@#{resource_name}", res)
  end

  def resource_name
    self.class.resource_class.name.underscore
  end

  # Plural resources

  def resources
    instance_variable_get(:"@#{resources_name}") ||
      self.resources = decorate_query(resources_base)
  end

  def resources=(res)
    instance_variable_set(:"@#{resources_name}", res)
  end

  def resources_name
    resource_name.pluralize
  end

  def resources_base
    self.class.resource_class.where(nil)
  end

  def resources_query
    filtered(scoped(resources_base))
  end

  def find_base
    filtered(scoped(included(resources_base)))
  end

  # Decorations

  def decorate_query(res)
    filtered(paged(sorted(scoped(included(res)))))
  end

  def filtered(arel)
    keys = self.class.resources_params || []
    where_hash = params.slice(*keys)
    where_hash = where_hash.permit(where_hash.keys)
    arel = arel.where(where_hash) unless where_hash.blank?
    arel
  end

  def included(res)
    res
  end

  def paged(arel)
    if params[:per].to_i <= 0
      arel.page(params[:page]).per(Kaminari.config.default_per_page)
    else
      arel.page(params[:page]).per(params[:per])
    end
  end

  def scoped(res)
    res
  end

  def sorted(arel)
    arel.order(id: :desc)
  end

  module ClassMethods
    attr_accessor :resource_class, :resources_params, :resource_representer, :find_method

    def filter_resources_by(*rparams)
      self.resources_params = rparams
    end

    def represent_with(representer_class)
      self.resource_representer = representer_class
    end

    def find_method(new_method = nil)
      if new_method.present?
        @find_method = new_method
      else
        @find_method ||= :find
      end
    end

    def resource_class
      @resource_class ||= controller_name.classify.constantize.tap do |klass|
        unless klass.included_modules.include?(HalApi::RepresentedModel)
          klass.send(:include, HalApi::RepresentedModel)
        end
      end
    end
  end
end
