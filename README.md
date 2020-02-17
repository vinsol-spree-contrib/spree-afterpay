Spree Afterpay
===========================

Spree AfterPay is an extension that lets users make payments using AfterPay. Behind-the-scenes, this extension uses [Afterpay's API](https://docs.afterpay.com/) and Afterpay's Ruby Gem[https://github.com/bluethumbart/afterpay-ruby].

Installation
-------

1. Add this extension to your Gemfile with these lines:

        gem 'spree_afterpay', github: 'vinsol-spree-contrib/spree-afterpay', branch: 'master'
        gem 'afterpay-ruby', github: 'rajneeshsharma9/afterpay-ruby', branch: 'master'

2. Install the gem using Bundler:

        bundle install

3. Copy & run migrations

        bundle exec rails g spree_afterpay:install

4. Restart your server

        If your server was running, restart it so that it can find the assets properly.

And then execute:

    $ bundle

Configuration
-------

* Put this in an initializer(/initializers/afterpay.rb).

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

For getting app_id and secret key, please contact afterpay for merchant credentials.(https://retailers.afterpay.com/merchant-enquiry/)

* Create a new payment method in spree backend with Afterpay as provider and with auto_capture set to true

Working
-----------

* The user will start seeing afterpay as a payment option during checkout if the order value is between the limit set by afterpay for your account.

* If the users clicks on afterpay logo in the payment options, they will be redirected to afterpay portal to complete the payment.

* Upon completing the payment on afterpay portal they will be redirected back to the website to the success_url(sent to afterpay during checkout) if the payment was completed with or to cancel_url if the payment failed.

* The user will pay the order amount to afterpay in 4 installments and afterpay will transfer the complete amount to the merchant when the order is placed.


Screenshots
-----------

![Admin End](/screenshots/admin.png "Admin End")
![Front End](/screenshots/user.png "Front End")


Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

Contributing
------------

1. Fork the repo.
2. Clone your repo.
3. Run `bundle install`.
4. Run `bundle exec rake test_app` to create the test application in `spec/test_app`.
5. Make your changes.
6. Ensure specs pass by running `bundle exec rspec spec`.
7. Submit your pull request.

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/themes/vinsoldotcom-theme/images/new_img/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2020 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
