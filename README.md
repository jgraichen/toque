# Toque - The Cap of a Chef

[![Build Status](https://travis-ci.org/jgraichen/toque.png?branch=master)](https://travis-ci.org/jgraichen/toque)

**Toque** combines the power of *chef-solo* and *capistrano*. It allows you to
run chef cookbooks with chef-solo as part of your capistrano deploy process.

## Installation

Add this line to your application's Gemfile:

    gem 'toque'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toque

After capifying your project add to your `Capfile`:

```ruby
require 'toque'
```

You can install chef by running `cap toque:chef:install` otherwise it will be
installed on first `run_list` call. **Toque** uses chef omnibus installer to
install a complete self-contained embedded chef environment.

You can specify a specific chef version by setting `:chef_version` to
something different to `nil`. If an already installed chef with a different version
exists **toque** will run omnibus installer with specified version to
override installed chef.

See `cap toque:config` for more options.

## Usage

**Toque** assumes your cookbooks to be in `config/cookbooks` or
`vendor/cookbooks`. One way is to use `config/cookbooks` for your own
application cookbook(s) and `vendor/cookbooks` for community cookbooks managed
by [librarian-chef](https://github.com/applicationsonline/librarian-chef).

You can configure *librarian-chef* to use `vendor/cookbooks` as cookbook path:

```bash
$ librarian-chef config path ./vendor/cookbooks --local
```

In your deploy configuration you can now run `toque.run_list` with a list of
recipes you want to execute. You can run chef more then once with different
list.

For example if you want to setup the server before deploying your app run
your setup recipe right at the start:

```ruby
before "deploy:update_code" do
  toque.run_list 'recipe[awesome::setup]'
end
```

After deploying your app you may need to create a config for your application
like `database.yml` or redis configuration:

```ruby
after "deploy:create_symlink" do
  toque.run_list 'recipe[awesome::configure]'
end
```

## Configuration

By default all capistrano options are available in your node configuration:

```ruby
# config/deploy.rb

set :application, 'awesomeium'
set :deploy_to, "/var/www/#{application}"
set :user, 'awesomeix'

# config/cookbooks/awesome/recipes/configure.rb

template File.join(node[:deploy_to], 'config', 'database.yml') do
  source 'database.yml.erb'
  owner node[:user]
  recursive true
end
```

### Available options

```bash
$ bundle exec cap toque:config
  * 2013-04-08 09:02:33 executing `toque:config'
set :chef_debug,                   false
set :chef_omnibus_installer_url,   "http://www.opscode.com/chef/install.sh"
set :chef_solo,                    "/opt/chef/bin/chef-solo"
set :chef_version,                 "10.24.0"
set :cookbooks_paths,              ["config/cookbooks", "vendor/cookbooks"]
set :databags_path,                "config/databags"
set :toque_pwd,                    "/tmp/toque"
```

## Thanks

Thanks to [roundsman](https://github.com/iain/roundsman) doing even some more
tasks like installing ruby and chef via rubygems. I've decided to make up
something new to use omnibus installer right from the start.

Also take a look at
[capistrano-spec](https://github.com/technicalpickles/capistrano-spec) allowing
some really great capistrano testing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

You can run a simple vagrant based test by running `bundle exec rspec spec/spec_toque.rb`.
