chef_gem 'json'

require 'json'
require 'net/https'
require 'uri'

attributes = node['github_keys']

if attributes['create_user']
  user attributes['username'] do
    home      "/home/#{attributes['username']}"
    shell     attributes['shell']
    supports  :manage_home => true
  end
end

if !::Dir.exists?("/home/#{attributes['username']}")
  raise "#{attributes['username']} home dir not found"
end

directory "/home/#{attributes['username']}/.ssh" do
  action :create
  owner  attributes['username']
  group  attributes['username']
  mode   '0700'
end

people = []

ruby_block "build array of people" do
  block do
    uri = URI.parse("https://api.github.com/orgs/#{attributes['github_org']}/members")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      result.each do |doc|
        people << doc["login"]
      end
    else
      raise "Couldn't access github api for organization members"
    end
  end
  only_if { attributes['force_key_load'] || !::File.exists?("/home/#{attributes['username']}/.ssh/authorized_keys") }
end

keys = {}

ruby_block "get individual public keys" do
  block do
    people.each do |person|
      uri = URI.parse("https://api.github.com/users/#{person}/keys")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if response.code == "200"
        result = JSON.parse(response.body)
        keys[person] = []
        result.each do |doc|
          keys[person] << doc["key"]
        end
      else
        raise "Couldn't access github api for #{person} keys"
      end
    end
  end
  only_if { attributes['force_key_load'] || !::File.exists?("/home/#{attributes['username']}/.ssh/authorized_keys") }
end

template "/home/#{attributes['username']}/.ssh/authorized_keys" do
  source 'authorized_keys.erb'
  owner attributes['username']
  group attributes['username']
  mode  '0600'
  variables :people_keys => keys
  only_if { attributes['force_key_load'] || !::File.exists?("/home/#{attributes['username']}/.ssh/authorized_keys") }
end
