module Spree
  class AfterpayResponseService

    def initialize(afterpay_service)
      @afterpay_service = afterpay_service
      @status = afterpay_service.payment_request.success?
    end

    def success?
      @status
    end

    def captured?
      @status
    end

    def authorization
      nil
    end

    def transaction_id
      @afterpay_service.payment_request.transaction_id
    end

    def to_s
      Spree.t(:unable_to_capture, scope: [:afterpay_response_service])
    end

  end
end
