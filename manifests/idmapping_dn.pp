#
define nifi_registry::idmapping_dn (
  $pattern = undef,
  $value = undef,
  $index = undef,
  $ensure = 'present'
) {

  assert_type(String[1], $pattern)
  assert_type(String[1], $value)
  assert_type(Integer[0, 99], $index)

  if($index==0){
    $real_index =''
  }else {
    #1 is 2
    $real_index=$index+1
  }
  $id_mapping_props= {
    "nifi.registry.security.identity.mapping.pattern.dn${real_index}" => $pattern,
    "nifi.registry.security.identity.mapping.value.dn${real_index}" => $value,
  }

  nifi_registry::config_properties {"nifi_idmapping_configs_${index}":
    properties => $id_mapping_props,
  }
}
