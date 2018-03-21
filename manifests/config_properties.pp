#
define nifi_registry::config_properties (
  $conf_dir = $::nifi_registry::conf_dir,
  $properties = {}
){
  assert_type(Hash[String,Scalar], $properties)
  $path = "${conf_dir}/nifi-registry.properties"

  if ! empty($properties) {
    $changes = $properties.map |String $key, Scalar $value| {
      "set ${key} '${value}'"
    }
    augeas {"update-nifi-registry-properties-${title}":
      lens => 'Properties.lns',
      incl => $path,
      changes => $changes,
      show_diff => true,
      notify => Service[$::nifi_registry::service_name],
    }
  }
}
