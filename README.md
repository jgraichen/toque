# Toque - Cap of a Chef

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
something different to `:latest` or `nil`. An already installed version of
chef will not be upgraded.

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

after "deploy:create_symlink" do
  toque.run_list 'recipe[awesome::configure]'
end

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

## Thanks

Thanks to [roundsman](https://github.com/iain/roundsman) doing even some more
tasks like installing ruby and chef via rubygems. I've decided to make up
something new to use omnibus installer right from the start.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
