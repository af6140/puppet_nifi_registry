#
define nifi_registry::authorizer(
  String $conf_dir = $::nifi_registry::conf_dir,
  Hash $ldap_user_group_properties = $::nifi_registry::ldap_user_group_properties
) {
  concat {"${conf_dir}/authorizers.xml":
    ensure => 'present',
    warn => false,
    owner => $::nifi_registry::user,
    group => $::nifi_registry::group,
    mode => '0644',
    ensure_newline => true,
  }
  concat::fragment{ 'authorizers_start':
    order => '01',
    target => "${conf_dir}/authorizers.xml",
    content => "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<!--\nThis file is managed by Puppet. DO NOT EDIT\n-->\n<authorizers>\n",
  }

  concat::fragment{ 'authorizers_end':
    order => '99',
    target => "${conf_dir}/authorizers.xml",
    content => "\n</authorizers>",
  }

  $file_user_group_provider_identifier = 'file-user-group-provider'
  $ldap_user_group_provider_identifier = 'ldap-user-group-provider'
  $composite_user_group_provider_identifier = 'composite-user-group-provider'
  $access_policy_provider_identifier = 'file-access-policy-provider'


  nifi_registry::user_group::file_provider{'file_user_group_provider':
    identifier => $file_user_group_provider_identifier,
    initial_admin_identity => $::nifi_registry::initial_admin_identity,
  }

  if ! empty($ldap_user_group_properties) {
    nifi_registry::user_group::ldap_provider {'ldap_user_group_provider':
      identifier => $ldap_user_group_provider_identifier,
      properties => $ldap_user_group_properties,
    }
    nifi_registry::user_group::composite_provider{'composite_user_group_provider':
      identifier => $composite_user_group_provider_identifier,
      component_providers => [$file_user_group_provider_identifier, $ldap_user_group_provider_identifier],
    }
    $real_user_group_provider_identifier = $composite_user_group_provider_identifier
  }else {
    $real_user_group_provider_identifier = $file_user_group_provider_identifier
  }

  nifi_registry::access_policy {'access_policy':
    identifier => $access_policy_provider_identifier,
    user_group_provider => $real_user_group_provider_identifier,
  }

  concat::fragment{ 'authorizer_entry':
    order => '98',
    target => "${conf_dir}/authorizers.xml",
    content => template('nifi_registry/frag_authorizer.erb'),
  }
}
