require "pundit"
require_relative 'formatter'
require_relative 'json_errors'

module ActAsJsonapi
  module Controller
    extend ActiveSupport::Concern
    include Formatter
    include JSONErrors

    def self.include(base)
      base.include Pundit

      base.extend ClassMethods
    end

    def index
      authorize model
      render_json_api serializer.new(_resources, serializer_options).serializable_hash
    end

    def show
      authorize _resource
      render_json_api serializer.new(_resource).serializable_hash
    end

    def update
      authorize model

      render_not_found && return if _resource.kind_of? NullObject

      if _resource.update_attributes _resource_params
        render_json_api serializer.new(_resource).serializable_hash, status: :reset_content
      else
        render_unprocessable_entity
      end
    end

    def destroy
      authorize _resource

      _resource.destroy
      render_json_api serializer.new(_resource).serializable_hash, status: :no_content
    end

    module ClassMethods
      def new(*args, &block)
        instance = super
        instance.instance_variable_set :@model, @model if @model
        instance.instance_variable_set :@serializer, @serializer if @serializer
        instance
      end

      def model_set(model)
        @model = model
      end

      def serializer_set(serializer)
        @serializer = serializer
      end
    end

    private

    def page
      @page ||= params[:page] || 1
    end

    def limit
      @limit ||= params[:limit] || 10
    end

    def meta
      @meta ||= params[:meta].eql?("true")
    end

    def filter
      @filter ||= params[:filter] || {}
    end

    def model
      @model ||= controller_name.classify.constantize
    end

    def serializer
      @serializer ||= "#{model.name}Serializer".constantize
    end

    def set_resource=(val)
      @_resource = val
    end

    def _resource
      @_resource ||= policy_scope(model).find_by_id(params[:id]) || NullObject.new
    end

    def _resources
      @_resources ||= apply_filter(policy_scope(model))
        .page(page)
        .per(limit)
    end

    def resource_params
      params.require(:data)
    end

    def serializer_options
      {
        params: {meta: meta},
        links: serializer_links,
        meta: serializer_meta,
        include: serializer_include
      }
    end

    def serializer_include
      @serializer_include ||= []
    end

    def serializer_meta
      @serializer_meta ||= {
        pages: { total: _resources.total_pages, current: _resources.current_page },
        results: { total: _resources.total_count, current: _resources.size }
      }
    end

    def serializer_links
      @serializer_links ||= {
        nav: {
          self: get_link_for(:self),
          first: get_link_for(:first),
          last: get_link_for(:last),
          prev: get_link_for(:prev),
          next: get_link_for(:next)
        }
      }
    end

    def get_link_for(keyword)
      case keyword
      when :self
        index_url(page: page, limit: limit)
      when :first
        index_url(page: 1, limit: limit)
      when :last
        index_url(page: _resources.total_pages, limit: limit)
      when :prev
        index_url(page: _resources.prev_page, limit: limit) unless _resources.first_page?
      when :next
        index_url(page: _resources.next_page, limit: limit) unless _resources.last_page?
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    def index_url(options)
      unless ENV['HOST']
        raise "Environment variable 'HOST' not defined"
      end

      url_for controller: controller_name,
        action: :index,
        host: ENV['HOST'],
        **options
    end

    def allowed_filters
      model.column_names
    end

    def valid_filters
      filter.select { |_filter| allowed_filters.include? _filter }
    end

    def valid_values_from_filter(field)
      filter[field].split(',').reject(&:blank?).map {|val| "%#{val}%" }
    end

    def apply_filter(scope)
      valid_filters.each_pair do |field, values|
        scope = scope.where("#{field}::text ILIKE ANY ( array[?] )", valid_values_from_filter(field))
      end
      scope
    end
  end
end
