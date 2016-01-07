# Formatron

[![Build Status](https://travis-ci.org/formatron/formatron.svg?branch=master)](https://travis-ci.org/formatron/formatron?branch=master)
[![Coverage Status](https://coveralls.io/repos/formatron/formatron/badge.svg?branch=master&service=github)](https://coveralls.io/github/formatron/formatron?branch=master)
[![Dependency Status](https://gemnasium.com/formatron/formatron.svg)](https://gemnasium.com/formatron/formatron)

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

For the full list of commands and options

```
formatron help [COMMAND]
```

### Project generation

To initialize a bootstrap configuration including a VPC and Chef Server

```
formatron generate bootstrap
```

To initialize an instance configuration with a dependency on a named bootstrap configuration

```
formatron generate instance
```

To initialize an AWS credentials file

```
formatron generate credentials
```

### Deploy and provision

To deploy a configuration with the given target specifier

```
formatron deploy TARGET
```

To provision a configuration with the given target specifier

```
formatron provision TARGET
```

To destroy a configuration and clean up its cookbooks, etc

```
formatron destroy TARGET
```

### Bash command completion

Add the following to your `.bashrc`

```
eval "$(formatron completion-script)"
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
