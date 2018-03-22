#
# This class is called from nifi_registry for service config.
#
class nifi_registry::config {
  $min_heap_args = "-Xms${::nifi_registry::min_heap}"
  $max_heap_args = "-Xmx${::nifi_registry::max_heap}"

  $bootstrap_properties = {
      'java.arg.2' => $min_heap_args,
      'java.arg.3' => $max_heap_args,
      'java.arg.8' => '-XX:CodeCacheMinimumFreeSpace=10m',
      'java.arg.9' => '-XX:+UseCodeCacheFlushing',
      'java.arg.13'=> '-XX:+UseG1GC',
  }

  nifi_registry::bootstrap_properties { 'bootstrap_jvm_conf':
    properties => $bootstrap_properties,
  }

  # login provider configuration
  concat {"${::nifi_registry::conf_dir}/identity-providers.xml":
    ensure => 'present',
    warn => false,
    owner => $::nifi_registry::user,
    group => $::nifi_registry::group,
    mode => '0644',
    ensure_newline => true,
  }
  concat::fragment{ 'id_provider_start':
    order => '01',
    target => "${::nifi_registry::conf_dir}/identity-providers.xml",
    content => "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<!--\nThis file is managed by Puppet. DO NOT EDIT\n-->\n<identityProviders>\n",
  }

  concat::fragment{ 'id_provider_end':
    order => '99',
    target => "${::nifi_registry::conf_dir}/identity-providers.xml",
    content => "\n</identityProviders>",
  }

  #id provider configs is optional
  # identity provider
  if ! empty($::nifi_registry::ldap_identity_provider_properties) {
    if $::nifi_registry::ldap_identity_provider_properties['authentication_strategy'] {
      assert_type(ENUM['ANONYMOUS', 'SIMPLE', 'LDAPS', 'START_TLS'], $::nifi_registry::ldap_identity_provider_properties['authentication_strategy'])
    }
    nifi_registry::ldap_provider { 'ldap_provider':
      provider_properties => $::nifi_registry::ldap_identity_provider_properties,
    }
  }

  #authorizers.xml
  $merged_ldap_user_group_configs = deep_merge($::nifi_registry::ldap_identity_provider_properties, $::nifi_registry::ldap_user_group_properties)
  #remove not appliable keys
  $normailzed_ldap_user_group_configs = delete($merged_ldap_user_group_configs, 'identity_strategy')

  if $normailzed_ldap_user_group_configs['authentication_strategy'] {
    assert_type(ENUM['ANONYMOUS', 'SIMPLE', 'LDAPS', 'START_TLS'], $normailzed_ldap_user_group_configs['authentication_strategy'])
  }

  nifi_registry::authorizer {'nifi_registry_authorizer':
    ldap_user_group_properties => $normailzed_ldap_user_group_configs,
  }

  if ! empty($::nifi_registry::id_mappings) {
    #use index 0 to override default pattern
    $nifi_registry::id_mappings.each |$id_index,  $entry| {
      $conf_index = $entry['index']
      $conf_ensure = $entry['ensure']
      if $conf_index {
        $real_index = $conf_index
      }else {
        $real_index = $id_index
      }

      if $conf_ensure {
        $real_ensure = $conf_ensure
      }else {
        $real_ensure = 'present'
      }
      nifi_registry::idmapping_dn { "ldap_id_mapping_${id_index}":
        pattern => $entry['pattern'],
        value => $entry['value'],
        index => $real_index,
        ensure => $real_ensure,
        notify => Service[$::nifi_registry::service_name],
      }
    }

  }

  #configs
  #ssl
  if $::nifi_registry::config_ssl{
    if ! $::nifi_registry::initial_admin_identity or empty($::nifi_registry::initial_admin_identity) {
      fail('When setup secure nifi_registry instance, initial admin identity is required')
    }
  }
  nifi_registry::security {'security':
    conf_dir => $::nifi_registry::conf_dir,
    cacert_path             => $::nifi_registry::ca_cert_path,
    node_cert_path          => $::nifi_registry::server_cert_path,
    node_private_key_path   => $::nifi_registry::server_key_path,
    initial_admin_cert_path => $::nifi_registry::admin_cert_path,
    initial_admin_key_path  => $::nifi_registry::admin_key_path,
    keystore_password  => $::nifi_registry::keystore_pass,
    key_password       => $::nifi_registry::key_pass,
  }
}
