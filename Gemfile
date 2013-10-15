source 'https://rubygems.org'

ruby '2.0.0'

# --- Core modules ---
gem 'rails'       , '4.0.0'
gem 'pg'
gem 'sass-rails'  , '~> 4.0.0'
gem 'uglifier'    , '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jbuilder'    , '~> 1.2'
gem 'oj'
# Redis
gem 'redis'
gem 'redis-store', git: 'git@github.com:daiweilu/redis-store.git'
gem 'redis-rails', '~> 4.0.0'
# Template engine
gem 'slim'

# --- Development and Test ---
group :development, :test do
  gem 'debugger'
  gem 'rspec-rails', '~> 2.0'
  gem 'awesome_print'
  gem 'factory_girl_rails'
end

# --- Production ---
gem 'autoprefixer-rails', group: :production
# gem 'puma'         , group: :production
# gem 'newrelic_rpm'


# --- Misc ---
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end




# Use Capistrano for deployment
# gem 'capistrano', group: :development

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
