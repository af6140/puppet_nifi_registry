# == Class nifi_registry::config
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
    owner => 'nifi',
    group => 'nifi',
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
    nifi_registry::ldap_provider { 'ldap_provider':
      provider_properties => $::nifi_registry::ldap_identity_provider_properties,
    }
  }

  #authorizers.xml
  $normailzed_ldap_user_group_configs = deep_merge($::nifi_registry::ldap_identity_provider_properties, $::nifi_registry::ldap_user_group_properties)
  nifi_registry::authorizer {'nifi_registry_authorizer':
    ldap_user_group_properties => $normailzed_ldap_user_group_configs,
  }

}
