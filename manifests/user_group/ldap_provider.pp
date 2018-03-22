#
define nifi_registry::user_group::ldap_provider(
  String $conf_dir = $::nifi_registry::conf_dir,
  String $identifier = 'ldap-user-group-provider',
  String $provider_class = 'org.apache.nifi.registry.security.ldap.tenants.LdapUserGroupProvider',
  Hash $properties = {},
) {
  $default_ldap_properties = {
    'authentication_strategy' => 'START_TLS',
    'manager_DN' => '',
    'manager_password' => '',
    'TLS_-_keystore' => '',
    'TLS_-_keystore_password' => '',
    'TLS_-_keystore_type' => '',
    'TLS_-_truststore' => '',
    'TLS_-_truststore_password' => '',
    'TLS_-_truststore_type' => '',
    'TLS_-_client_auth' => '',
    'TLS_-_client_protocol' => '',
    'TLS_-_shutdown_gracefully' => '',
    'referral_strategy' => 'FOLLOW',
    'connect_timeout' => '10 secs',
    'read_timeout' => '60 secs',
    'url' => '',
    'page_size' => '100',
    'sync_interval' => '30 mins',
    'user_search_base' => '',
    'user_object_class' => 'person',
    'user_search_filter' => '',
    'user_identity_attribute' => '',
    'user_group_name_attribute' =>'',
    'group_search_base' => '',
    'group_object_class' => 'person',
    'group_search_filter' => '',
    'group_name_attribute' => '',
    'group_member_attribute' =>'',
  }

  $active_ldap_provider_properties = deep_merge($default_ldap_properties, $properties)
  assert_type(Hash[String, String], $active_ldap_provider_properties)

  $tmp = $active_ldap_provider_properties.map |$key, $value | {
    #replace single _ with space
    $keyspecs = split($key, '_')
    $cap_keyspecs = $keyspecs.map | $key_spec| {
      #if part is all uppercase, do not transform
      if $key_spec =~ /[A-Z0-9]+/ {
        $cap_key_spec = $key_spec
      }else {
        $cap_key_spec = capitalize($key_spec)
      }
      $cap_key_spec
    }

    $cap_key = join($cap_keyspecs, ' ')
    [$cap_key, $value]
  }

  $flat_tmp = flatten($tmp)

  $normalized_ldap_provider_properties = hash($flat_tmp)
  #LDAP user group provider 'User Search Scope' must be specified when 'User Search Base' is set

  if ! empty($normalized_ldap_provider_properties['user_search_base']) {
    assert_type(ENUM['OBJECT','ONE_LEVEL','SUBTREE'], $normalized_ldap_provider_properties['user_search_scope'])
  }

  if ! empty($normalized_ldap_provider_properties['group_search_base']) {
    assert_type(ENUM['OBJECT','ONE_LEVEL','SUBTREE'], $normalized_ldap_provider_properties['group_search_scope'])
  }

  concat::fragment { "user_group_frag_${identifier}":
    order   => '03',
    target  => "${conf_dir}/authorizers.xml",
    content => template('nifi_registry/user_group_provider/frag_ldap_provider.erb'),
  }
}
