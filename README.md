# ActAsJsonapi

Act as JSONAPI is a small and flexible gem on top of `jsonapi_serializer` and `pundit` gems.

By including Act as JSONAPI in your controllers you instantly
get all basic controller actions for the model and authorization checks.

Plus formatted responses with meta, links and pagination as in JSON:API documentation
and consistent error formatting.

You can override the model and serializer if the name of the controller doesn't match the model.
The json formatter and errors can be used separatly.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'act_as_jsonapi'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install act_as_jsonapi

## Notes
Project isn't fully polished so there are some considerations to have while adding the gem to a project.

Notes:
- ActAsJsonapi assumes the project will use `pundnit`.
- Project needs to have gem `jsonapi-serializer` in Gemfile.
- Project needs some kinde of pagination gem like `kaminari` that adds the `#page` method.
- Project needs to respond to `current_user` for Pundit. Gem like `devise` can be used.

## Usage

To get all actions, error handling and serialization at once. (Controller includes Formatter and JSONErrors)

This will give BooksController the methods `#index`, `#show`, `#update` and `#destroy`, with authorization checks.
The model and serializer are atomatically loaded based on the name of the controller and it expects that Rails
conventions were followed.
```ruby
class BooksController < ApplicationController
  include ActAsJsonapi::Controller
end
```

If you want to include the just `render_json_api` method.
```ruby
class BooksController < ApplicationController
  include ActAsJsonapi::Formatter

  def index
    render_json_api BookSerializer.new(@books).serializable_hash
  end
end
```

Just the error handling
```ruby
class BooksController < ApplicationController
  include ActAsJsonapi::JSONErrors

  def index
    #your code...
    render_error :unprocessable_entity, :err_workflow_update, 'my message'
  end
end
```

Using `rescue_errors` examples
```ruby
class ApplicationController < ActionController::API
  include ActAsJsonapi::JSONErrors

  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActionController::BadRequest, with: :render_bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
end
```

```ruby
class ApplicationController < ApplicationController
  include ActAsJsonapi::JSONErrors

  rescue_from ActiveRecord::RecordNotFound, :with => :err_record_not_found

  private

  def err_record_not_found(ex)
    render_error :unprocessable_entity, :err_record_not_found, ex.message
  end
end
```

## Overriding

`ActAsJsonapi::Controller` provides two handy class methods to change the model and/or serializer name.

```ruby
class API::Inventory < ApplicationController
  include ActAsJsonapi::Controller

  model_set Book
  serializer_set BookSerializer

  #...
end
```

Another common practice is to override the `_resource` and `_resources` methods

```ruby
class BookController < ApplicationController
  include ActAsJsonapi::Controller

  #...

  private

  def _resource
    @_resouce = #Complex query that returns one Book
  end

  def _resources
    @_resouces = #Complex query that returns a collection of Books
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/act_as_jsonapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/act_as_jsonapi/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActAsJsonapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/act_as_jsonapi/blob/master/CODE_OF_CONDUCT.md).
