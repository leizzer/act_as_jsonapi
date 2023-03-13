require 'jsonapi/serializer'

module JSONAPI
  # This module allows serialization of custom error objects to remain compliant
  # with JSON:API specification
  module ErrorSerializer
    extend ActiveSupport::Concern

    included do
      attr_accessor :with_root_key

      include JSONAPI::Serializer

      def initialize(resource, options = {})
        if resource.is_a? StandardError
          resource
        else
          resource = Array.wrap(resource)
          resource.collect! { |res| OpenStruct.new(res) }
        end
        super
        @with_root_key = options[:with_root_key] != false
      end

      def hash_for_one_record
        serialized_hash = [super[:data].dig(:attributes)]
        !with_root_key ? serialized_hash : { errors: serialized_hash }
      end

      def hash_for_collection
        serialized_hash = super[:data]&.map { |err| err[:attributes] }
        !with_root_key ? serialized_hash : { errors: serialized_hash }
      end
    end
  end
end
