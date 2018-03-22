# == Class nifi_registry::params
#
# This class is meant to be called from nifi_registry.
# It sets variables according to platform.
#
class nifi_registry::params {
  $user = 'nifi_registry'
  $group = 'nifi_registry'
  case $::osfamily {
    'RedHat', 'Amazon': {
      $package_name = 'nifi-registry'
      $service_name = 'nifi-registry'
      $package_version = 'present'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # $default_id_mappings = [
  #   {
  #     'pattern' => '^CN=(.*?), OU=(.*?), O=(.*?), L=(.*?), ST=(.*?), C=(.*?)$',
  #     'value' => '$1'
  #   },
  #   {
  #     'pattern' => '^C=(.*?), ST=(.*?), O=(.*?), OU=(.*?), CN=(.*?)$',
  #     'value' => '$5'
  #   },
  #   {
  #     'pattern' => '^CN=(.*?)$',
  #     'value' => '$1'
  #   }
  # ]
}
