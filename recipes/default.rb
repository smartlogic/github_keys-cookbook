chef_gem 'json' do
  # https://www.chef.io/blog/2015/02/17/chef-12-1-0-chef_gem-resource-warnings/
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
