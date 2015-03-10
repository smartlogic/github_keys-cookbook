actions :update
default_action :update

attribute :username       , kind_of: String, name_attribute: true, required: true
attribute :github_org     , kind_of: [String, NilClass]
attribute :github_users   , kind_of: Array, default: []
attribute :force_key_load , kind_of: [ TrueClass, FalseClass ], default: false
attribute :additional_keys, kind_of: Hash, default: {}
