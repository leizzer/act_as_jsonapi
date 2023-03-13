module ActAsJsonapi
  module Formatter
    extend ActiveSupport::Concern

    # Render json response and set content type to 'application/vnd.api+json'
    def render_json_api(serializable_hash, options = {})
      options.merge!(json_api_content_type)
      args = { json: serializable_hash }.merge(options)
      render args
    end

    private

    def json_api_content_type
      { content_type: 'application/vnd.api+json' }
    end
  end
end
