Description
===========
Installs/Configures a server user with keys based on members of a github 
organization

Requirements
============
None

Attributes
==========
None

Usage
=====

To be used inside your custom cookbooks. Does nothing as a standard included 
recipe.

Example to set the smartlogic github orgs member keys, another user's keys, and 
a deployer key to `/home/user_name/.ssh/authorized_keys`, and force the reload 
of the keys every time.

```ruby
include_recipe 'github_keys' # run the default recipe to ensure the json gem is available to chef

github_keys_update 'user_name' do
  github_org 'smartlogic'
  github_users ( ['smarterlogic'] )
  additional_keys ( { "deploy-key" => ["CAFEBEEF"] } )
  force_key_load true
end
```
