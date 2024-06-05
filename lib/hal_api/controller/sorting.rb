module HalApi::Controller::Sorting
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :allowed_sort_names
      class_attribute :default_sort
    end
  end

  module ClassMethods
    def sort_params(args)
      self.allowed_sort_names = args[:allowed].map(&:to_s).uniq
      self.default_sort = args[:default]
      if default_sort && !default_sort.is_a?(Array)
        self.default_sort = Array[default_sort]
      end
    end
  end

  def sorts
    @sorts ||= parse_sorts_param
  end

  def sorted(arel)
    apply_sorts = !sorts.blank? ? sorts : default_sort
    if apply_sorts.blank?
      super
    else
      arel.order(*apply_sorts)
    end
  end

  private

  # support ?sorts=attribute,attribute:direction params
  # e.g. ?sorts=published_at,updated_at:desc
  # desc is default if a direction is not specified
  def parse_sorts_param
    sorts_array = []
    allowed_sorts = self.class.allowed_sort_names

    # parse sort param for name of the column and direction
    # default is descending, because I say so, and we have a bias towards the new
    (params[:sorts] || '').split(',').each do |str|
      name, direction = (str || '').split(':', 2).map { |s| s.to_s.strip }
      name = name.underscore
      direction = direction.blank? ? 'desc' : direction.downcase
      unless allowed_sorts.include?(name)
        hint = "Valid sorts are: #{allowed_sorts.join(' ')}"
        raise HalApi::Errors::BadSortError.new("Invalid sort: #{name}", hint)
      end
      unless ['asc', 'desc'].include?(direction)
        hint = "Valid directions are: asc desc"
        raise HalApi::Errors::BadSortError.new("Invalid sort direction: #{direction}", hint)
      end
      sorts_array << { name => direction }
    end
    sorts_array
  end
end
