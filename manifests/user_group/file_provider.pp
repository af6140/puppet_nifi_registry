#
define nifi_registry::user_group::file_provider(
  String $conf_dir = $::nifi_registry::conf_dir,
  String $identifier = 'file-user-group-provider',
  String $provider_class = 'org.apache.nifi.registry.security.authorization.file.FileUserGroupProvider',
  String[1] $initial_admin_identity = undef
) {
  concat::fragment { "user_group_frag_${identifier}":
    order   => '02',
    target  => "${conf_dir}/authorizers.xml",
    content => template('nifi_registry/user_group_provider/frag_file_provider.erb'),
  }
}
