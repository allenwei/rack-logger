# RackLogger

## Installation

Add this line to your application's Gemfile:

    gem 'rack_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack_logger

## Usage

  use RackLogger, LOGGER, {:label => "ActiveRecord", :class => ActiveRecord::LogSubscriber}

will generate two logs per request:

  Started GET "http://localhost:3000/ping" for 127.0.0.1 at 2012-08-13 23:22:23 +0800 Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_0) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.77 Safari/537.1

  Completed GET http://localhost:3456/ping 200 in 0.76ms (ActiveRecord: 0.30ms)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
