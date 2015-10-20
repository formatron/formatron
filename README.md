# Formatron

[![Build Status](https://travis-ci.org/pghalliday/formatron.svg?branch=refactor2)](https://travis-ci.org/pghalliday/formatron?branch=refactor2)
[![Coverage Status](https://coveralls.io/repos/pghalliday/formatron/badge.svg?branch=refactor2&service=github)](https://coveralls.io/github/pghalliday/formatron?branch=refactor2)
[![Dependency Status](https://gemnasium.com/pghalliday/formatron.svg)](https://gemnasium.com/pghalliday/formatron)

Simple AWS CloudFormation configuration with Chef Server

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formatron'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formatron

## Usage

To initialize a bootstrap configurstaion including a VPC and Chef Server

```
formatron bootstrap <dirname>
```

To initialize an instance configuration with a dependency on a named bootstrap configuration

```
formatron instance <bootstrap_configuration> <dirname>
```

To deploy a configuration with the given target specifier

```
formatron deploy <target>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/formatron/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
