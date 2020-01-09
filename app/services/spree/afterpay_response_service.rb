module Spree
  class AfterpayResponseService

    def initialize(status)
      @status = status
    end

    def success?
      @status
    end

    def captured?
      @status || false
    end

    def authorization
      nil
    end

    def to_s
      Spree.t(:unable_to_capture, scope: [:afterpay_response_service])
    end

  end
end
