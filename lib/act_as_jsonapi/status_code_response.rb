module ActAsJsonapi
  module StatusCodeResponse
    SYMBOL_TO_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE
    STATUS_CODE_TO_SYMBOL = SYMBOL_TO_STATUS_CODE.invert

    def self.serializable(error_status, detail, detail_meta)
      if error_status.kind_of? Integer
        serializable_from_int(error_status, detail, detail_meta)
      else
        serializable_from_sym(error_status, detail, detail_meta)
      end
    end

    def self.serializable_from_int(code, detail, detail_meta)
      code_i = code.to_i
      error_sym = STATUS_CODE_TO_SYMBOL[code_i]

      return {} unless error_sym

      serializable error_sym, detail, detail_meta
    end

    def self.serializable_from_sym(error_sym, detail, detail_meta)
      status_code = SYMBOL_TO_STATUS_CODE[error_sym]

      return {} unless status_code
      error_name = error_sym.to_s

      {
        id: SecureRandom.uuid,
        title: error_name.gsub(/_/, ' '),
        detail: detail,
        code: status_code.to_s,
        status: status_code.to_s,
        meta: {
          error: detail_meta
        }
      }
    end
  end
end
