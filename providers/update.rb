
begin
  require 'json'
rescue LoadError
  Chef::Log.error("Missing gem 'json'. Use the default github_keys recipe to install it first.")
  raise
end

require 'net/https'
require 'uri'

def key_files_exist?(username)
  ::File.exists?("/home/#{username}/.ssh/authorized_keys")
end

def get_people(org, users)
  people = []

  if org
    uri = URI.parse("https://api.github.com/orgs/#{org}/members")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      result.each do |doc|
        people << doc["login"]
      end
    elsif response.code == "403"
      limit_resets_at = Time.at(response['x-ratelimit-reset'].to_i)
      Chef::Log.fatal "Couldn't access github api for '#{org}' organization members. Rate limit resets at #{limit_resets_at}"
      raise
    else
      Chef::Log.fatal "Couldn't access github api for '#{org}' organization members. Response from api: #{response.code}"
      raise
    end
  end

  Array(users).each do |user|
    people << user
  end

  people
end

def get_keys(people, additional_key_pairs)
  keys = {}
  people.each do |person|
    uri = URI.parse("https://github.com/#{person}.keys")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == "200"
      results = response.body.split("\n")
      keys[person] = []
      results.each do |key|
        keys[person] << key
      end
    else
      raise "Couldn't access github api for #{person} keys"
    end
  end

  additional_key_pairs.each_pair do |desc, additional_keys|
    keys[desc] = Array(additional_keys)
  end

  keys
end

action :update do
  username = @new_resource.username
  if key_files_exist?(username) && !@new_resource.force_key_load
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    unless ::Dir.exists?("/home/#{username}")
      Chef::Log.fatal("User '#{username}' home directory does not already exist")
      raise
    end
    directory "/home/#{username}/.ssh" do
      action :create
      owner  username
      group  username
      mode   '0700'
    end

    people = get_people(@new_resource.github_org, @new_resource.github_users)

    keys = get_keys(people, @new_resource.additional_keys)

    template "/home/#{username}/.ssh/authorized_keys" do
      cookbook 'github_keys'
      source 'authorized_keys.erb'
      owner  username
      group  username
      mode  '0600'
      variables :people_keys => keys
    end
  end
  new_resource.updated_by_last_action(true)
end
