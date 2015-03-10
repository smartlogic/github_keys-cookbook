
user 'deploy' do
  home '/home/deploy'
  supports :manage_home => true
end

github_keys_update 'deploy' do
  github_org 'smartlogic'
  github_users ( ['smarterlogic'] )
  additional_keys ( { 'test_key' => ['12345DEADBEEF', '12345CAFEBEEF'] } )
  force_key_load true
end
