require_relative 'status_code_response'
require_relative 'request_error_serializer'

module ActAsJsonapi
  module JSONErrors
    extend ActiveSupport::Concern

    def serializable(error_status, detail, detail_meta)
      StatusCodeResponse.serializable(error_status, detail, detail_meta)
    end

    def translate_detail_code(detail_code)
      detail = I18n.t("error_messages.#{detail_code.to_s}")
      return detail unless detail.include?("translation missing")
      detail = I18n.t("error_messages.err_standard")
    end

    def render_error(error_status, detail_code = nil, detail_meta = nil )
      detail = translate_detail_code(detail_code)
      serializer = ::RequestErrorSerializer.new serializable(error_status, detail , detail_meta)
      render_json_api serializer, status: error_status
    end

    def render_not_found
      render_error :not_found
    end

    def render_bad_request
      render_error :bad_request
    end

    def render_not_authorized
      render_error :unauthorized
    end

    def render_forbidden(ex)
      render_error :forbidden, :err_forbidden, ex.message
    end

    def render_failed_dependency
      render_error :failed_dependency
    end

    def render_unprocessable_entity
      render_error :unprocessable_entity
    end

    def render_service_unavailable
      render_error :service_unavailable
    end

    def render_conflict_request
      render_error :conflict
    end

    private

    # Render json response and set content type to 'application/vnd.api+json'
    def render_json_api(serializable_hash, options = {})
      options[:content_type] = 'application/vnd.api+json'
      args = { json: serializable_hash }.merge(options)
      render args
    end
  end
end
