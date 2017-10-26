module HalApi::Controller::Actions
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :valid_params
    end
  end

  def index
    respond_with index_collection, index_options
  end

  def show
    respond_with root_resource(show_resource), show_options
  end

  def create
    create_resource.tap do |res|
      consume! res, create_options
      hal_authorize res
      res.save!
      respond_with root_resource(res), create_options
    end
  end

  def update
    update_resource.tap do |res|
      consume! res, show_options
      hal_authorize res
      res.save!
      respond_with root_resource(res), show_options
    end
  end

  def destroy
    destroy_resource.tap do |res|
      hal_authorize res
      res.destroy
      head :no_content
    end
  end

  private

  def destroy_redirect
    { action: 'index' }
  end

  def index_options
    valid_params_for_action(:index).tap do |options|
      options[:_keys] = options.keys
      options[:represent_with] = Api::PagedCollectionRepresenter
    end
  end

  def create_options
    show_options.tap do |options|
      options[:location] = ''
    end
  end

  def show_options
    valid_params_for_action(:show).tap do |options|
      options[:_keys] = options.keys
      if self.class.resource_representer
        options[:represent_with] = self.class.resource_representer
      end
    end
  end

  def valid_params_for_action(action)
    (params.permit(*self.class.valid_params_list(action)) || {}).tap do |p|
      p[:zoom] = zoom_param if zoom_param
    end
  end

  def zoom_param
    @zoom_param ||= begin
      if (zp = params[:zoom]) && !zp.nil?
        Array(zp.split(',')).map(&:strip).compact.sort
      end
    end
  end

  def root_resource(resource)
    resource.tap { |res| res.is_root_resource = true }
  end

  def hal_authorize(resource)
    if !respond_to?(:authorize)
      define_singleton_method(:authorize) do |_resource|
        true
      end
      singleton_class.send(:alias_method, :hal_authorize, :authorize)
    end

    authorize(resource)
  end


  module ClassMethods
    def allow_params(action, *params)
      self.valid_params ||= {}
      valid_params[action.to_sym] = Array(params).flatten
    end

    def valid_params_list(action)
      (valid_params || {})[action.to_sym]
    end
  end
end
