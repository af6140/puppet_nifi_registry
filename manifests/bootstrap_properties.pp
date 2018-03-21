#
define nifi_registry::bootstrap_properties (
  $conf_dir = $::nifi_registry::conf_dir,
  $properties = {}
){
  assert_type(Hash[String,Scalar], $properties)
  $path = "${conf_dir}/bootstrap.conf"
  if ! empty($properties) {
    $changes = $properties.map |String $key, Scalar $value| {
      "set ${key} '${value}'"
    }

    augeas {"update-nifi-registry-bootstrap-${title}":
      lens => 'Properties.lns',
      incl => $path,
      changes => $changes,
      show_diff => true,
      notify => Service[$::nifi_registry::service_name],
    }
  }
}
