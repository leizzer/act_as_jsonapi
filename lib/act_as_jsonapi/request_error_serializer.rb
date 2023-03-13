require_relative 'jsonapi_error_serializer'

# Request Error Serializer
# Provides additional information about problems encountered while performing
# a request operation.  The possible attributes are:
#   +id+      a unique identifier for this particular occurrence of the problem.
#   +title+   a short, human-readable summary of the problem
#   +detail+  a human-readable explanation specific to this occurrence of the problem
#   +code+    an application-specific error code, expressed as a string value.
#   +status+  the HTTP status code applicable to this problem, expressed as a string value.
class RequestErrorSerializer
  include JSONAPI::ErrorSerializer

  attributes  :id,
              :title,
              :detail,
              :code,
              :status,
              :meta

  # This is a generic active model error serializer that transform an
  # ActiveModel::Errors object to a JSON:API compliant error serializer
  # @params [ActiveModel::Errors] ActiveModel::Errors object
  def self.from_active_model_errors(errors)
    error_array = errors.full_messages.map do |error_msg|
      {
        id: SecureRandom.uuid,
        title: error_msg,
        detail: error_msg,
        code: 'CLIENT400',
        status: '400',
        meta: {error: error_msg}
      }
    end

    new(error_array)
  end
end

