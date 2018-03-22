#
define nifi_registry::user_group::composite_provider(
  String $conf_dir = $::nifi_registry::conf_dir,
  String $identifier = 'composite-user-group-provider',
  String $provider_class = 'org.apache.nifi.registry.security.authorization.CompositeUserGroupProvider',
  Array $component_providers = [],
) {

  if size(unique($component_providers)) >0 {
    concat::fragment { "user_group_frag_${identifier}":
      order   => '04',
      target  => "${conf_dir}/authorizers.xml",
      content => template('nifi_registry/user_group_provider/frag_composite_provider.erb'),
    }
  }
}
