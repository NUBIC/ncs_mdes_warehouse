source 'https://rubygems.org'

gemspec

# With the large number of potentially compatible versions of actionpack,
# activesupport, and builder, bundler takes infinite time to resolve unless you
# lock it down a little.
group :resolver_hint do
  gem 'actionpack', '~> 3.2.8'
end

group :development do
  # for YARD
  gem 'rdiscount'
end

group :test do
  gem 'dm-sqlite-adapter', '~> 1.2.0'
end
