module Spree
  class AfterpayConfiguration < Preferences::Configuration

    preference :afterpay_logo_url, :string, default: 'https://site-assets.afterpay.com/assets/afterpay_logo-c6f18616342f97c47c82457cf06eb00e0249830809ff092c32727f5dff8a1eba.svg'

  end
end
