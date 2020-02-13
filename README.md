# spree-afterpay
Unofficial Integration of AfterPay Payment gateway for spree

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'spree_afterpay', github: 'vinsol-spree-contrib/spree-afterpay', branch: 'master'
gem 'afterpay-ruby', github: 'rajneeshsharma9/afterpay-ruby', branch: 'master'
```

And then execute:

    $ bundle

## Usage

You need to configure Afterpay using your Merchant ID and secret.

For Rails, put this in your initializer.

```ruby
Afterpay.configure do |config|
  config.app_id = <app_id>
  config.secret = <secret>

  # Sets the environment for Afterpay
  # defaults to sandbox
  # config.env = "sandbox" # "live"

  # Sets the user agent header for Afterpay requests
  # Refer https://docs.afterpay.com/au-online-api-v1.html#configuration
  # config.user_agent_header = {pluginOrModuleOrClientLibrary}/{pluginVersion} ({platform}/{platformVersion}; Merchant/{merchantId}) { merchantUrl }
  # Example
  # config.user_agent_header = "Afterpay Module / 1.0.0 (rails/ 5.1.2; Merchant/#{ merchant_id }) #{ merchant_website_url }"

end
```
