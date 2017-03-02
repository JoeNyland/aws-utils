# Aws::Utils

A collection of utilities for use on AWS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws-utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws-utils

## Usage

### `update-public-ip-in-route53`

Gets the public IP address of the local EC2 instance and creates an entry in Route53.

```
update-public-ip-in-route53 --fqdn server.example.com
```

### `update-public-ip-in-security-group`

Gets the public IP address of the local machine and creates a VPC Security Group in EC2.

```
update-public-ip-in-security-group --security-group-name my-sg
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JoeNyland/aws-utils. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

