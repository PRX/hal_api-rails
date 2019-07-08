# HalApi::Rails

[![Build Status](https://travis-ci.org/PRX/hal_api-rails.svg?branch=master)](https://travis-ci.org/PRX/hal_api-rails)

Welcome to hal_api-rails. This is a binding between the responders /
roar / roar-rails gems and the the PRX HAL api.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hal_api-rails'
```

Then add a gem for paging through ActiveRecord result sets:
```ruby
gem 'kaminari'
```


And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hal_api-rails

## Usage

This gem provides a number of additions to the `roar` gem HAL support.

There are several parts of it that need to be used in your apps:

1) Add to your API controllers:

```ruby
require 'hal_api/rails'

class Api::BaseController < ApplicationController
  include HalApi::Controller
  ...
end
```

2) Add to your `ActiveRecord` models used in your API (perhaps in a base model class):
```ruby
class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include RepresentedModel
end
```

3) Use the base representer, define your own CURIEs:
```ruby
class Api::BaseRepresenter < HalApi::Representer
  curies(:prx) do
    [{
      name: :foo,
      href: "http://foo.bar/relation/{rel}",
      templated: true
    }]
  end

  def index_url_params
    '{?page,per,zoom}'
  end

  def show_url_params
    '{?zoom}'
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hal_api-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
