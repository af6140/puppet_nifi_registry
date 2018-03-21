
#
define nifi_registry::access_policy(
  $identifier = 'file-access-policy-provider',
  $nifi_access_nodes = $::nifi_registry::nifi_access_nodes,
  $initial_admin_identity = $::nifi_registry::initial_admin_identity,
  String $user_group_provider = undef,
){
  concat::fragment { "access_policy_frag_${identifier}":
    order   => '80',
    target  => "${::nifi_registry::conf_dir}/authorizers.xml",
    content => template('nifi_registry/frag_access_policy.erb'),
  }
}
