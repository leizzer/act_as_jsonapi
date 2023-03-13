# frozen_string_literal: true

module ActAsJsonapi
  require_relative "act_as_jsonapi/version"
  require_relative "act_as_jsonapi/controller"
  require_relative "act_as_jsonapi/formatter"
  require_relative "act_as_jsonapi/json_errors"

  class Error < StandardError; end
end
