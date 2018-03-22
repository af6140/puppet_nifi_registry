#
define nifi_registry::security(
  String $conf_dir = $::nifi_registry::conf_dir,
  $cacert_path             = $::nifi_registry::ca_cert_path,
  $node_cert_path          = $::nifi_registry::server_cert_path,
  $node_private_key_path   = $::nifi_registry::server_key_path,
  $initial_admin_cert_path = $::nifi_registry::admin_cert_path,
  $initial_admin_key_path  = $::nifi_registry::admin_key_path,
  $keystore_password  = $::nifi_registry::keystore_password,
  $key_password       = $::nifi_registry::key_password,
  $client_auth = $::nifi_registry::client_auth,
) {

  if $initial_admin_cert_path and $cacert_path and $initial_admin_key_path and $node_cert_path and $node_private_key_path and $keystore_password {
    validate_absolute_path($cacert_path)
    validate_absolute_path($node_cert_path)
    validate_absolute_path($node_private_key_path)
    validate_absolute_path($initial_admin_cert_path)
    validate_absolute_path($initial_admin_key_path)

    java_ks { 'nifi_truststore:ca':
      ensure       => latest,
      certificate  => $cacert_path,
      target       => "${conf_dir}/truststore.jks",
      trustcacerts => true,
      password     => $keystore_password
    }
    java_ks { "nifi_keystore:${fqdn}":
      ensure      => latest,
      target      => "${conf_dir}/keystore.jks",
      certificate => $node_cert_path,
      private_key => $node_private_key_path,
      password    => $keystore_password,
      destkeypass => $key_password,
    }
    $security_properties = {
        'nifi.registry.security.keystore'          => "${conf_dir}/keystore.jks",
        'nifi.registry.security.keystoreType'      => 'jks',
        'nifi.registry.security.keystorePasswd'    => $keystore_password,
        'nifi.registry.security.keyPasswd'         => $key_password,
        'nifi.registry.security.truststore'        => "${conf_dir}truststore.jks",
        'nifi.registry.security.truststorePasswd'  => $keystore_password,
        'nifi.registry.security.truststoreType'    => 'jks',
        'nifi.registry.security.needClientAuth'    => "${client_auth}",
        'nifi.registry.web.http.port'              => '',
        'nifi.registry.web.https.port'              => "${::nifi_registry::web_https_port}",
    }
    nifi_registry::config_properties { 'nifi_security_props':
      properties => $security_properties
    }
  }else {
     $security_properties = {
      'nifi.registry.security.keystore'          => '',
      'nifi.registry.security.keystoreType'      => '',
      'nifi.registry.security.keystorePasswd'    => '',
      'nifi.registry.security.keyPasswd'         => '',
      'nifi.registry.security.truststore'        => '',
      'nifi.registry.security.truststorePasswd'  => '',
      'nifi.registry.security.truststoreType'    => '',
      'nifi.registry.security.needClientAuth'    => 'false',
      'nifi.registry.web.http.port'              => "${::nifi_registry::web_http_port}",
      'nifi.registry.web.https.port'              => '',
    }
    nifi_registry::config_properties { 'nifi_security_props':
      properties => $security_properties
    }

  }

}
